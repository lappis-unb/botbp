require 'rufus-scheduler'
require 'json'
require 'tzinfo'

module BotBP
  class ReportManager
    def initialize
      @scheduler = Rufus::Scheduler.new
      @data_daily = DataDaily.new
      @sao_paulo_timezone = TZInfo::Timezone.get('America/Sao_Paulo')
    end

    def schedule_reports
      @scheduler.every '15s' do
        current_time = @sao_paulo_timezone.now.strftime('%H:%M')
        report_config = @data_daily.read("report")
        report_config.each do |report|
          daily_time = report['daily-time']
          telegram_user_id = report['telegram-user-id']
          gitlab_user_tag = report['gitlab-user-tag']
          regex_find = report['regex-find']
          puts daily_time
          if current_time == daily_time
            process_report(telegram_user_id, gitlab_user_tag, regex_find)
          end
        end
      end

      @scheduler.join
    end

    def process_report(telegram_user_id, gitlab_user_tag, regex_find)
      # Implemente aqui a lógica para processar o relatório
      # Você pode chamar a função desejada passando os parâmetros necessários.
      puts "Processando relatório para user ID: #{telegram_user_id}, GitLab User Tag: #{gitlab_user_tag}, Regex: #{regex_find}"
      # Chame a função ou método apropriado aqui com os dados do relatório.
    end
  end
end