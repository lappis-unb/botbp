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
<<<<<<< HEAD
<<<<<<< Updated upstream
=======
      puts data
      puts type
      puts data[type]
>>>>>>> Stashed changes
=======
      puts data
      puts type
      puts data[type]
>>>>>>> 785d687 (fix: atualizando maneira de lidar com os dados)
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
<<<<<<< HEAD
<<<<<<< Updated upstream
=======
=======
>>>>>>> 785d687 (fix: atualizando maneira de lidar com os dados)
    def initialize
      @file_path = "./data/users.json"
    end

<<<<<<< HEAD
>>>>>>> Stashed changes
=======
>>>>>>> 785d687 (fix: atualizando maneira de lidar com os dados)
    def create(type, telegram_user_id, telegram_user_phone, gitlab_user_tag)
      new_user = {
        "telegram_user_id": telegram_user_id,
        "telegram_user_phone_number": telegram_user_phone,
        "gitlab_user_tag": gitlab_user_tag
      }

      record = { 'type' => type }.merge(new_user)

      data = load_data
      data[record['type']] << record
      save_data(data)
    end

    private
    def load_data
      JSON.parse(File.read(@file_path))
    rescue Errno::ENOENT
<<<<<<< HEAD
<<<<<<< Updated upstream
      { "admins" => [], "client" => [] }
=======
      { "admins" => [] }
>>>>>>> Stashed changes
=======
      { "admins" => [] }
>>>>>>> 785d687 (fix: atualizando maneira de lidar com os dados)
    end
  end

  class DataGitlabProjects < DataManager
<<<<<<< HEAD
<<<<<<< Updated upstream
=======
=======
>>>>>>> 785d687 (fix: atualizando maneira de lidar com os dados)
    def initialize
      @file_path = "./data/gitlab_projects.json"
    end

<<<<<<< HEAD
>>>>>>> Stashed changes
=======
>>>>>>> 785d687 (fix: atualizando maneira de lidar com os dados)
    def create(type, project_id)
      new_project = {
        "project_id": project_id
      }

      record = { 'type' => type }.merge(new_project)

      data = load_data
      data[record['type']] << record
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
<<<<<<< HEAD
<<<<<<< Updated upstream
=======
=======
>>>>>>> 785d687 (fix: atualizando maneira de lidar com os dados)
    def initialize
      @file_path = "./data/daily.json"
    end

<<<<<<< HEAD
>>>>>>> Stashed changes
=======
>>>>>>> 785d687 (fix: atualizando maneira de lidar com os dados)
    def create(type, telegram_user_id, gitlab_user_tag, regex_find, daily_time)
      new_daily = {
        "telegram-user-id": telegram_user_id,
        "gitlab-user-tag": gitlab_user_tag,
        "regex-find": regex_find,
        "daily-time": daily_time
      }

      record = { 'type' => type }.merge(new_daily)

      data = load_data
      data[record['type']] << record
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