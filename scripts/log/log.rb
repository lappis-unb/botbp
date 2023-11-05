require 'logger'

module BotBP
  class Log
    def initialize(log_file_path, log_level = Logger::INFO)
      @log_file_path = log_file_path
      @log_level = log_level
    end

    def log(message, level = @log_level)
      @logger = create_logger
      @logger.add(level) { message }
      puts "#{level}: #{message}"
      @log_file.close
    end

    private

    def create_logger
      ensure_log_file_exists
      @log_file = File.open(@log_file_path, 'a')
      logger = Logger.new(@log_file)
      logger.level = @log_level
      logger
    end

    def ensure_log_file_exists
      unless File.exist?(@log_file_path)
        File.new(@log_file_path, 'w').close
      end

      lines = File.readlines(@log_file_path)

      if lines.length >= 1000
        File.open(@log_file_path, 'w') do |file|
          file.puts lines[lines.length - 999..-1]
        end
      end
    end
  end
end
