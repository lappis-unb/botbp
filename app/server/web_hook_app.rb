require 'sinatra'
require 'json'

module BotBP
  # Inicializa o servidor webhook e recebe os eventos
  class WebHookApp < Sinatra::Base
    set :server, :thin # Configura o servidor Thin

    post '/gitlab-webhook' do
      payload = JSON.parse(request.body.read)

      BotBP::Manager.bot_telegram.send_update(payload)

      # Responde ao GitLab com um status 200 (OK)
      status 200
    end

  end
end
