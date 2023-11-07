require 'json'
require 'gitlab'

module BotBP
  # Esta classe encapsula a funcionalidade de interação com a api do GitLab.
  class GitlabAPI
    # Inicializa a classe GitLabAPI e configura a comunicacao com a api do gitlab.
    def initialize
      # Configura as credenciais para acessar a api do GitLab.
      Gitlab.configure do |config|
        config.endpoint = ENV["GITLAB_ENDPOINT"]
        config.private_token = ENV["GITLAB_PRIVATE_TOKEN"]
      end
    end

    def get_projects_by_group(group_id)
      projects = Gitlab.group_projects(group_id)
      projects.map { |project| project.id }
    end

    # Obtém uma lista de issues para um projeto específico.
    #
    # @param project_id [Integer] O ID do projeto.
    # @return [Array] Uma lista de issues.
    def get_issues(project_id)
      Gitlab.issues(project_id)
    end

    # Obtém uma lista de mrs para um projeto específico.
    #
    # @param project_id [Integer] O ID do projeto.
    # @return [Array] Uma lista de mrs.
    def get_merge_requests(project_id)
      Gitlab.merge_requests(project_id)
    end

    # Obtém comentários de um texto, opcionalmente filtrando por regex personalizada.
    #
    # @param description [String] O texto para procurar comentários.
    # @param regex [Regexp, nil] (Opcional) A expressão regular para filtrar comentários.
    # @return [Array] Uma lista de comentários correspondentes.
    def get_comment(description, regex = nil)
      if regex
        matches = description.scan(regex).map { |match| match[0].strip }
      else
        matches = description.scan(/<!--(.*?)-->/m).map { |match| match[0].strip }
      end

      matches
    end
  end
end

