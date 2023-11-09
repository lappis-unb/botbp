require 'json'
require 'telegram/bot'
require 'dotenv/load'
require_relative '../data/data_manager'

module BotBP
  class TelegramAPI
    def initialize
      @token = ENV['TELEGRAM_TOKEN']
      @log = BotBP::Log.new(log_file_path = "telegram_api.log")
      @users = BotBP::DataUsers.new
      @servers = BotBP::DataServers.new
      @gitlab = BotBP::GitlabAPI.new
    end

    def run_bot
      puts "Rodando o bot"
      Telegram::Bot::Client.run(@token) do |bot|
        @bot_running = bot
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
            when '/teste'

            when '/stop'
              bot.api.send_message(chat_id: message.from.id, text: "Até logo!")
            end
          end
        end
      end
    end

    def send_update(request)
      puts request.header.read
      payload = JSON.parse(request.body.read)
      text = ""
      if payload["object_kind"] == "push"
        user_username = payload["user_username"]
        user_name = payload["user_name"]
        repository_name = payload["repository"]["name"]
        repository_web_url = payload["repository"]["homepage"]
        commits = payload["commits"]

        header = "*PUSH* - [#{user_username}](https://gitlab.com/#{user_username})\n\n#{user_name} acabou de enviar #{commits.length} commits para o nosso repositório [#{repository_name}](#{repository_web_url})! \uD83D\uDE80"
        commit_messages = commits.map { |commit| "[#{commit['title']}]#{commit['url']}" }.join("\n")
        text = "#{header}\n\n#{commit_messages}"
      end

      servers = @servers.read("server_update")

      servers.each do |server|
        @bot_running.api.send_message(chat_id: server["chat_id"],
                                      message_thread_id: server["message_thread_id"],
                                      disable_web_page_preview: server["disable_web_page_preview"],
                                      disable_notification: server["disable_notification"],
                                      protect_content: server["protect_content"],
                                      parse_mode: "MarkdownV2",
                                      text: text)
      end
    end

    private

    def start_chat(bot, message)
      response = verify_user(message)
      # bot.api.send_message(chat_id: message.from.id, text: "id: #{message.from.id} | #{response}")
      @log.log("response; #{message.from.id}; #{response}")
      kb =[]
      case response
      when 'admin'
        title = "*Opcoes de admin*"
        kb.append(show_admin_buttons)
        kb.append(show_client_buttons)
      when 'client'
        title = "*Opcoes de utilizador*"
        kb.append(show_client_buttons)
      else
        title = "*Opcoes de usuario*"
        kb.append(show_guest_buttons)
      end
      title += "\n\nEscolha a opcao que deseja gerenciar:"
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
      bot.api.send_message(chat_id: message.from.id, text: title, parse_mode: "MarkdownV2", reply_markup: markup)
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

    def show_admin_buttons
      [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Admins', callback_data: "manage_admins"),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Gitlab', callback_data: "manage_gitlab")
       ]
    end

    def show_client_buttons
      [
         Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Conta', callback_data: "manage_account"),
         Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Daily', callback_data: "manage_daily")
       ]
    end

    def show_guest_buttons
      [
         Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Gerenciar sua conta', callback_data: "manage_account"),
         Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Gerenciar sua daily', callback_data: "manage_daily")
       ]
    end

    def verify_user (message)
      users = @users.read('admin') # Lê a lista de usuários "admin"
      if users.count == 0
        @log.log("#{message.from.id}; users nil", Logger::WARN)
        @users.create('admin', message.from.id, '@' + message.from.username, '')
        return 'admin'
      else
        admin = users.find { |admin| admin['telegram_user_id'] == message.from.id }
        return 'admin' if admin
      end

      'none'
    end
  end
end
