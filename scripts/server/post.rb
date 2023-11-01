require 'httparty'

module BotBP
  class PostToWebHook
    def post_to_webhook(url, data)
      HTTParty.post(url, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
    end
  end
end