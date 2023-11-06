require 'json'

module BotBP
  class DataManager
    def initialize(file_path)
      @file_path = file_path
    end

    def create(record)
      data = load_data
      data[record['type']] << record
      save_data(data)
    end

    def read(type)
      data = load_data
      data[type]
    end

    def update(type, id, updated_record)
      data = load_data
      records = data[type]
      if records[id]
        records[id] = updated_record
        save_data(data)
        true
      else
        false
      end
    end

    def delete(type, id)
      data = load_data
      records = data[type]
      if records[id]
        records.delete_at(id)
        save_data(data)
        true
      else
        false
      end
    end

    private

    def save_data(data)
      File.write(@file_path, JSON.pretty_generate(data))
    end
  end

  class DataUsers < DataManager
    def initialize
      @file_path = "./data/users.json"
    end

    def create(type, telegram_user_id, telegram_user_tag, gitlab_user_tag)
      new_user = {
        "telegram_user_id": telegram_user_id,
        "telegram_user_tag": telegram_user_tag,
        "gitlab_user_tag": gitlab_user_tag
      }

      data = load_data
      data[type] << new_user
      save_data(data)
    end

    private
    def load_data
      JSON.parse(File.read(@file_path))
    rescue Errno::ENOENT
      { "admin" => [] }
    end
  end

  class DataGitlabProjects < DataManager
    def initialize
      @file_path = "./data/gitlab_projects.json"
    end

    def create(type, project_id)
      new_project = {
        "project_id": project_id
      }

      data = load_data
      data[type] << new_project
      save_data(data)
    end

    private
    def load_data
      JSON.parse(File.read(@file_path))
    rescue Errno::ENOENT
      { "projects" => [] }
    end
  end

  class DataDaily < DataManager
    def initialize
      @file_path = "./data/daily.json"
    end

    def create(type, telegram_user_id, gitlab_user_tag, regex_find, daily_time)
      new_daily = {
        "telegram-user-id": telegram_user_id,
        "gitlab-user-tag": gitlab_user_tag,
        "regex-find": regex_find,
        "daily-time": daily_time
      }

      data = load_data
      data[type] << new_daily
      save_data(data)
    end

    private
    def load_data
      JSON.parse(File.read(@file_path))
    rescue Errno::ENOENT
      { "report" => [] }
    end
  end
end