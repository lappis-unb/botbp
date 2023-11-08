require 'sinatra'
require 'json'

module BotBP
  class WebHookApp < Sinatra::Base
    set :bind, '0.0.0.0'
    set :port, 80

    post '/bot-bp' do

      BotBP::Manager.bot_telegram.send_update(request.body.read)

      status 200
    end
  end
end
