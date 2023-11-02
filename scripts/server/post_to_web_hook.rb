require 'httparty'

# Namespace para o Bot do BP
module BotBP
  # Classe auxiliar para simular chamadas para o webhook
  class PostToWebHook
    # Envia um post http para o servidor
    #
    # @param url [String] O caminho para o webhook
    # @param data [json] O conteudo a ser enviado
    def post_to_webhook(url, data)
      HTTParty.post(url, body: data.to_json, headers: { 'Content-Type' => 'application/json' })
    end
  end
end