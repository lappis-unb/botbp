require_relative 'api/gitlab_api'
require_relative 'api/telegram_api'
require_relative 'server/web_hook_app'
require_relative 'server/post_to_web_hook'
require_relative 'log/log'

module BotBP
  class Manager
    def start_software
      start_bot
      start_webhook
      start_test
    end

    private

    def start_bot
      thread_bot = Thread.new do
        bot_telegram = BotBP::TelegramAPI.new
        bot_telegram.run_bot
      end

      thread_bot.join
    end

    def start_webhook
      thread_webhook = Thread.new do
        webhook = BotBP::WebHookApp
        webhook.run!
      end

      thread_webhook.join
    end

    def start_test
      thread_test = Thread.new do
        url = 'http://localhost:4567/gitlab-webhook'
        request_body = { key1: 'value1', key2: 'value2' }.to_json
        post_html = BotBP::PostToWebHook.new
        sleep(6)
        10.times do
          post_html.post_to_webhook(url, request_body)
          sleep(3)
        end
      end

      thread_test.join
    end
  end
end

app = BotBP::Manager.new
app.start_software

