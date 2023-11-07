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

    end
  end
end