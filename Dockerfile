# Use uma imagem base que inclua Ruby
FROM ruby:3.0

# Configuração do diretório de trabalho
WORKDIR /app

# Copie o arquivo Gemfile e Gemfile.lock para o contêiner
COPY Gemfile Gemfile.lock ./

# Instale as dependências Ruby
RUN bundle install

# Copie o restante do código-fonte para o contêiner
COPY . .

# Comando de inicialização
CMD ["ruby", "./app/manager.rb"]
