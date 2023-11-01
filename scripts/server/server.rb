require 'sinatra'
require 'json'

module BotBP
  class WebHookApp < Sinatra::Base
    post '/gitlab-webhook' do
      payload = JSON.parse(request.body.read)

      # Processar os dados recebidos do webhook do GitLab aqui
      # Você pode acessar os dados do GitLab através do objeto 'payload'

      # Exemplo: Imprimir o payload no console
      puts "Recebido um evento do GitLab:"
      puts JSON.pretty_generate(payload)

      # Responda ao GitLab com um status 200 (OK)
      status 200
    end
  end
end
