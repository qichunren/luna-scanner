require 'socket'
require 'net/ssh'

module LunaScanner
  class Logger
    class << self
      def info message, options={}
        if options[:time] == false
          $stderr.puts "\r#{message.to_s}"
        else
          $stderr.puts "\r#{Time.now.strftime("%H:%M:%S")} > #{message.to_s}"
        end
      end

      def success message, options={}
        if options[:time] == false
          $stderr.puts "\r\e[32m#{message.to_s}\e[0m"
        else
          $stderr.puts "\r#{Time.now.strftime("%H:%M:%S")} > \e[32m#{message.to_s}\e[0m"
        end
      end

      def error message, options={}
        if options[:time] == false
          $stderr.puts "\r\e[33m#{message.to_s}\e[0m"
        else
          $stderr.puts "\r#{Time.now.strftime("%H:%M:%S")} > \e[33m#{message.to_s}\e[0m"
        end
      end
    end
  end
end