# BotBP

## Objetivo

O objetivo do BotBP eh ajudar e motivar o time de desenvolvimento a comentarem de forma ativa em issues para que sejam reportadas de maneira automatica no grupo de daily.

## Como rodar o projeto

Atualmente basta seguir os passos:

Instalar as dependencias do projeto

```shell
bundle install
```

Iniciar o manager.rb

```shell
cd scripts/
ruby manager.rb
```

## Versoes

As versoes devem ser incrementadas de acordo com as seguintes condicoes:

### **vX.Y.Z**

**X**: versao estavel para uso com novas classes de funcionalidades criadas.

**Y**: versao estavel para uso com metodos e pequenas atualizacoes implementadas.

**Z**: versao estavel para uso com correcao de bugs.

---

### v0.1.0

#### Scripts

- **Manager**
  - (+) Cria Threads para cada funcionalidade e inicia todas elas
- **GitlabAPI**
  - (+) Inicia configuracao com a API
  - (+) Funcao para retornar as issues
  - (+) Funcao para retornar os mrs
  - (+) Funcao para encontrar textos em descricoes atravez de regex
- **TelegramAPI**
  - (+) Inicia configuracao com a API
  - (+) Funcao para iniciar o bot e realizar testes
- **WebHookApp**
  - (+) Abre uma rota webhook e imprime as informacoes
- **PostToWebHook**
  - (+) Envia um post http com parametros json para uma rota

#### Data

- **dailys**: Guarda informacoes a respeito do que o usuario que enviar para a daily.
- **gitlab-projects**: Guarda o id de todos os repositorios que devem ser reportados pelo telegram ao grupo do BP.
- **users**: Guarda as informacoes sobre telegram e gitlab de todos os usuarios.

#### Config

- **.gitignore**: Ignora algumas variaveis do .idea e .env.
- **.env**: Contem as chaves para configuracoes das APIs.
- **Gemfile**: Contem as gems utilizadas no projeto.

---
