require 'json'
require 'telegram/bot'
require 'dotenv/load'
require_relative '../../data/data_manager'

module BotBP
  class TelegramAPI
    def initialize
      @token = ENV['TELEGRAM_TOKEN']
      @users = BotBP::DataUsers.new
    end

    def run_bot
      Telegram::Bot::Client.run(@token) do |bot|
        bot.listen do |message|
          case message.text
          when '/start'
            response = verify_user(message.chat.id)
            case response
            when 'admin'
              bot.api.send_message(chat_id: message.chat.id, text: "id: #{message.chat.id} | admin")
            when 'client'
              bot.api.send_message(chat_id: message.chat.id, text: "id: #{message.chat.id} | client")
            when 'none'
              bot.api.send_message(chat_id: message.chat.id, text: "id: #{message.chat.id} | none")
            end
          when '/stop'
            bot.api.send_message(chat_id: message.chat.id, text: "Até logo!")
          end
        end
      end
    end

    def verify_user (user_id)
      users = @users.read('admin') # Lê a lista de usuários "admin"
      unless users.nil?
        admin = users.find { |admin| admin['telegram_user_id'] == user_id }
        return 'admin' if admin
      end

      'none'
    end
  end
end
