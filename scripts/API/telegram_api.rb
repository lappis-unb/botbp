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
            bot.api.send_message(chat_id: message.chat.id, text: "Olá, bem-vindo ao seu bot do Telegram!")
          when '/stop'
            bot.api.send_message(chat_id: message.chat.id, text: "Até logo!")
          end
        end
      end
    end
  end
end
