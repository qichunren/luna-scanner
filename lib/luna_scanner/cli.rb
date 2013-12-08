#encoding: utf-8
require 'optparse'

module LunaScanner
  class CLI

    def initialize()
      @options = {}
      option_parser = OptionParser.new do |opts|
        opts.banner = 'Luna Scanner toolkit.'

        @options[:scan] = false
        opts.on('-s', '--scan', 'Scan current LAN luna-client devices.') do
          @options[:scan] = true
        end

        opts.on_tail("-h", "--help", "luna_scanner usage.") do
          puts "Help message."
          puts "  * ddddd"
          puts "  * 13223223"
          puts opts
          exit 1
        end

        opts.on('-v', '--version', 'Display luna_scanner version.') do
          puts "luna_scanner v#{LunaScanner::VERSION}"
          exit 1
        end

      end.parse!

      puts @options.inspect
    end

    def execute
      if ARGV[0].to_s == '' || ARGV[0].to_s == 'scan'
        puts "Scan LAN devices ..."
        LunaScanner::Scanner.scan!
      elsif ARGV[0].to_s == 'web'
        puts "luna_scanner listen on 4567 port ..."
        LunaScanner::Web.run!
      end
    end

    def self.start
      self.new.execute
    end
  end
end