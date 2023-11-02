require_relative 'API/gitlab_api'
require_relative 'API/telegram_api'
require_relative 'server/web_hook_app'
require_relative 'server/post_to_web_hook'

webhook = BotBP::WebHookApp

thread_1 = Thread.new do
  webhook.run!
end

url = 'http://localhost:4567/gitlab-webhook'
request_body = { key1: 'value1', key2: 'value2' }.to_json

post_html = BotBP::PostToWebHook.new

thread_2 = Thread.new do
  sleep(3)
  10.times do
    post_html.post_to_webhook(url, request_body)
    sleep(3)
  end
end

thread_1.join
thread_2.join



