require 'sinatra'
require 'json'

module BotBP
  # Inicializa o servidor webhook e recebe os eventos
  class WebHookApp < Sinatra::Base
    set :server, :thin # Configura o servidor Thin

    post '/gitlab-webhook' do
      payload = JSON.parse(request.body.read)

      # Processar os dados recebidos do webhook do GitLab aqui
      # Você pode acessar os dados do GitLab através do objeto 'payload'

      puts "Recebido um evento do GitLab:"
      puts JSON.pretty_generate(payload)

      # Responde ao GitLab com um status 200 (OK)
      status 200
    end
  end
end
