require 'json'
require 'telegram/bot'
require 'dotenv/load'
require_relative '../../data/data_manager'

module BotBP
  class TelegramAPI
    def initialize
      @token = ENV['TELEGRAM_TOKEN']
      @users = BotBP::DataUsers.new
      @log = BotBP::Log.new(log_file_path = "telegram_api.log")
    end

    def run_bot
      Telegram::Bot::Client.run(@token) do |bot|
        bot.logger.info('Bot has been started')
        bot.listen do |message|
          puts message.class
          puts message.__attributes__
          case message
          when Telegram::Bot::Types::InlineQuery
            @log.log("inline-query; #{message.from.id}; #{message.query}")
            case message.query
            when "adm", "admin", "admins",
              inlines_admins(bot, message)
            end

          when Telegram::Bot::Types::CallbackQuery
            @log.log("callback-query; #{message.from.id}; #{message.data}")

          when Telegram::Bot::Types::Message
            @log.log("message; #{message.from.id}; #{message.text}")

            case message.text
            when '/start'
              start_chat(bot, message)
            when '/stop'
              bot.api.send_message(chat_id: message.from.id, text: "Até logo!")
            end
          end
        end
      end
    end

    def start_chat(bot, message)
      response = verify_user(message.from.id)
      bot.api.send_message(chat_id: message.from.id, text: "id: #{message.from.id} | #{response}")
      @log.log("response; #{message.from.id}; #{response}")
      case response
      when 'admin'
        show_admin_buttons(bot, message)
        show_client_buttons(bot, message)
      when 'client'
        show_client_buttons(bot, message)
      else
        show_guest_buttons(bot, message)
      end
    end

    def inlines_admins(bot, message)
      admins = @users.read("admin")
      results = [
        [1, 'Admins do bot', admins]
      ].map do |arr|
        Telegram::Bot::Types::InlineQueryResultArticle.new(
          id: arr[0].to_s,
          title: arr[1],
          input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(
            message_text: arr[2].map { |admin| admin["telegram_user_tag"] }.join("\n")
          )
        )
      end

      bot.api.answer_inline_query(inline_query_id: message.id, results: results)
    end

    def show_admin_buttons(bot, message)
      # Crie um teclado inline para opções de administrador
      keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Gerenciar Admins', callback_data: 'manage_admin'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Gerenciar repositorios do Gitlab', callback_data: 'manage_gitlab'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Gerenciar usuarios', callback_data: 'manage_users'),
        ]
      ])
      text_admin =
        "*OPCOES DE ADMIN*\n\nEscolha uma das opcoes"
      bot.api.send_message(chat_id: message.chat.id, text: text_admin, reply_markup: keyboard)
    end

    def show_client_buttons(bot, message)
      # Crie um teclado inline para opções de clientes
      keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Gerenciar sua conta', callback_data: 'manage_account'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Gerenciar sua daily', callback_data: 'manage_daily')
        ]
      ])
      text_client = "OPCOES DA SUA CONTA\n\nEscolha uma das opcoes"
      bot.api.send_message(chat_id: message.chat.id, text: text_client, reply_markup: keyboard)
    end

    def show_guest_buttons(bot, message)
      # Crie um teclado inline para opções de visitantes
      keyboard = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Opção para visitantes', callback_data: 'guest_option')
        ]
      ])
      bot.api.send_message(chat_id: message.chat.id, text: 'Escolha uma opção:', reply_markup: keyboard)
    end

    def verify_user (user_id)
      users = @users.read('admin') # Lê a lista de usuários "admin"
      if users.count == 0
        @log.log("#{user_id}; users nil", Logger::WARN)
        @users.create('admin', user_id, '', '')
        return 'admin'
      else
        admin = users.find { |admin| admin['telegram_user_id'] == user_id }
        return 'admin' if admin
      end

      'none'
    end
  end
end
