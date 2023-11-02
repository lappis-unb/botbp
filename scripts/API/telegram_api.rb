require 'json'
require 'telegram/bot'
require 'dotenv/load'

module BotBP
  class TelegramAPI
    def initialize
      @token = ENV['TELEGRAM_TOKEN']

    end

    def run_bot
      Telegram::Bot::Client.run(@token) do |bot|
        bot.listen do |message|
          case message.text
          when '/start'
            puts message.from.id
          when '/stop'
            bot.api.send_message(chat_id: message.chat.id, text: "Até logo!")
          end
        end
      end
    end

    def verify_user (user_id)

    end
  end
end
