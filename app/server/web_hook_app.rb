require 'sinatra'
require 'json'

module BotBP
  class WebHookApp < Sinatra::Base
    set :server, :thin
    set :port, 8080  # Defina a porta desejada, como 8080

    post '/bot-bp' do
      payload = JSON.parse(request.body.read)

      BotBP::Manager.bot_telegram.send_update(payload)

      status 200
    end
  end
end
