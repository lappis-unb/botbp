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
            when "admins",
              inlines_admins(bot, message)
            else
              bot.api.answer_inline_query(inline_query_id: message.id, results: nil)
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
      x_gitlab_event = request.env['HTTP_X_GITLAB_EVENT']

      parse_mode = "HTML"

      payload = JSON.parse(request.body.read)
      text = ""
      case x_gitlab_event
      when 'Push Hook'
        user_username = payload["user_username"]
        user_name = payload["user_name"]
        repository = payload["repository"]
        commits = payload["commits"]
      
        repository_name = repository["name"]
        repository_web_url = repository["homepage"]
        branch = payload["ref"].split("/").last
        branch_url = "#{repository_web_url}/-/tree/#{branch}?ref_type=heads"
      
        header = "<b>PUSH</b>\n\n"
        header += "<b>Repositório</b>: <a href='#{repository_web_url}'>#{repository_name}</a>\n"
        header += "<b>Branch</b>: <a href='#{branch_url}'>#{branch}</a>\n\n"
        header += "<a href='https://gitlab.com/#{user_username}'>#{user_name}</a> acabou de enviar #{commits.length} commits para o nosso repositório! 🚀"
      
        commit_messages = commits.map.with_index(1) do |commit, index|
          "#{index}. <a href='#{commit['url']}'>#{commit['title']}</a>"
        end.join("\n")
      
        text = "#{header}\n\n#{commit_messages}"      
      when 'Issue Hook'
        user_name = payload["user"]["name"]
        user_username = payload["user"]["username"]
        issue_title = payload["object_attributes"]["title"]
        issue_description = payload["object_attributes"]["description"]
        issue_url = payload["object_attributes"]["url"]
        issue_state = payload["object_attributes"]["action"]
        issue_labels = payload["labels"].map { |label| label["title"] }.join(", ")
        assignees = payload["assignees"]
        
        case issue_state
        when 'open'
          header = "🤭 <b>Issue criada</b>\n\n"
        when 'close'
          header = "😍 <b>Issue fechada</b>\n\n"
        when 'reopen'
          header = "😩 <b>Issue reaberta</b>\n\n"
        when 'update'
          header = "🫣 <b>Issue atualizada</b>\n\n"
        else
          header = "🤔 Nao identifiquei o estado da issue\n\n"
        end

        header += "<b>Autor</b>: <a href='https://gitlab.com/#{user_username}'>#{user_name}</a>\n"
        header += "<b>Título</b>: <a href='#{issue_url}'>#{issue_title}</a>\n"
        #header += "<b>Descrição</b>: #{issue_description}\n"
        #header += "<b>Estado</b>: #{issue_state}\n"
        header += "<b>Labels</b>: #{issue_labels}\n"

        gitlab_tags =[]
        if assignees.any?
          header += "\n\n"
          assignee_names = assignees.map do |assignee|
            gitlab_tags.append(assignee["username"])
            "<a href='https://gitlab.com/#{assignee["username"]}'>#{assignee["name"]}</a>"
          end
          header += "Assignees: #{assignee_names.join(", ")}"
        end
      
        text = "#{header}"

        gitlab_tags.each { |tag| send_update_to_user(tag, text, parse_mode) }
      when 'Merge Request Hook'
        user_name = payload["user"]["name"]
        merge_request_title = payload["object_attributes"]["title"]
        merge_request_description = payload["object_attributes"]["description"]
        merge_request_url = payload["object_attributes"]["url"]
        merge_request_source_branch = payload["object_attributes"]["source_branch"]
        merge_request_target_branch = payload["object_attributes"]["target_branch"]
        merge_request_state = payload["object_attributes"]["state"]
        merge_request_labels = payload["labels"].map { |label| label["title"] }.join(", ")
        last_commit_message = payload["object_attributes"]["last_commit"]["message"]
        last_commit_author = payload["object_attributes"]["last_commit"]["author"]["name"]
      
        header = "<b>NOVA SOLICITAÇÃO DE MERGE</b>\n\n"
        header += "<b>Autor</b>: #{user_name}\n"
        header += "<b>Título</b>: <a href='#{merge_request_url}'>#{merge_request_title}</a>\n"
        header += "<b>Branch de origem</b>: #{merge_request_source_branch}\n"
        header += "<b>Branch de destino</b>: #{merge_request_target_branch}\n"
        header += "<b>Estado</b>: #{merge_request_state}\n"
        header += "<b>Labels</b>: #{merge_request_labels}\n"
        #header += "<b>Último Commit</b>: #{last_commit_message}\n"
        #header += "<b>Autor do Último Commit</b>: #{last_commit_author}\n"
      
        text = "#{header}"
      end
      
      if text == ""
        text = x_gitlab_event
      end

      text = text.gsub(/<!--(.*?)-->/m, "")

      servers = @servers.read("server_update")

      servers.each do |server|
        @bot_running.api.send_message(chat_id: server["chat_id"],
                                      message_thread_id: server["message_thread_id"],
                                      disable_web_page_preview: server["disable_web_page_preview"],
                                      disable_notification: server["disable_notification"],
                                      protect_content: server["protect_content"],
                                      parse_mode: parse_mode,
                                      text: text)
      end
    end

    private

    def send_update_to_user(gitlab_user_tag, text, parse_mode)
      users = @users.read("users")
      user_id = nil

      users.each do |user|
        if user["gitlab_user_tag"] == gitlab_user_tag
          unless user["notify_issue"]
            return
          end

          user_id = user["telegram_user_id"]
          break
        end
      end

      if user_id
        @bot_running.api.send_message(chat_id: user_id,
                                      disable_web_page_preview: true,
                                      parse_mode: parse_mode,
                                      text: text)
      end
    end

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
      users = @users.read("users")
      admins = users.select { |user| user["type"] == "admin" }
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
      users = @users.read('users') # Lê a lista de usuários "admin"
      if users.count == 0
        @log.log("#{message.from.id}; users nil", Logger::WARN)
        @users.create('admin', message.from.id, '@' + message.from.username, '')
        return 'admin'
      else
        user = users.find { |user| user['telegram_user_id'] == message.from.id }
        return user["type"] if user
      end

      'none'
    end
  end
end
