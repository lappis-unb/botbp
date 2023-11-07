require_relative 'api/gitlab_api'
require_relative 'api/telegram_api'
require_relative 'server/web_hook_app'
require_relative 'server/post_to_web_hook'
require_relative 'log/log'
require_relative 'data/report_manager'
require 'thread'

module BotBP
  class Manager
    @@bot_telegram = nil
    @@threads = []

    def self.bot_telegram
      @@bot_telegram
    end

    def start_software
      # Inicie as threads
      start_bot
      start_webhook
      start_test
      start_report

      # Aguarde todas as threads concluírem
      @@threads.each(&:join)
    end

    private

    def start_bot
      thread_bot = Thread.new do
        @@bot_telegram = BotBP::TelegramAPI.new
        @@bot_telegram.run_bot
      end
      @@threads << thread_bot
    end

    def start_webhook
      thread_webhook = Thread.new do
        @webhook = BotBP::WebHookApp
        @webhook.run!
      end
      @@threads << thread_webhook
    end

    def start_test
      thread_test = Thread.new do
        url = 'http://localhost:4567/gitlab-webhook'
        request_body = { key1: 'value1', key2: 'value2' }.to_json
        post_html = BotBP::PostToWebHook.new
        sleep(6)
        10.times do
          puts "estou enviando a requisicao"
          post_html.post_to_webhook(url, request_body)
          sleep(3)
        end
      end
      @@threads << thread_test
    end

    def start_report
      thread_report = Thread.new do
        report_manager = BotBP::ReportManager.new
        report_manager.schedule_reports
      end
      @@threads << thread_report
    end
  end
end

app = BotBP::Manager.new
app.start_software
