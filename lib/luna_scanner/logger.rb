require 'socket'
require 'net/ssh'

module LunaScanner
  class Logger
    class << self
      def info message, options={}
        if options[:time] == false
          puts "\r#{message.to_s}"
        else
          puts "\r#{Time.now.strftime("%H:%M:%S")} > #{message.to_s}"
        end
      end

      def error message, options={}
        if options[:time] == false
          puts "\r\e[33m#{message.to_s}\e[0m"
        else
          puts "\r#{Time.now.strftime("%H:%M:%S")} > \e[33m#{message.to_s}\e[0m"
        end
      end
    end
  end
end