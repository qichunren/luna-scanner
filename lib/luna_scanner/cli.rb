#encoding: utf-8
require 'optparse'

module LunaScanner
  class CLI

    def initialize()
      @options = {}
      option_parser = OptionParser.new do |opts|
        opts.banner = 'Luna Scanner toolkit.'

        @options[:t] = 50
        opts.on('-t', '--thread_size COUNT', 'Set luna_scanner scan thread size.') do |thread_size|
          @options[:t] = thread_size.to_i
        end

        opts.on_tail("-h", "--help", "luna_scanner usage.") do
          puts "Luna Scanner usage:"
          puts "  luna_scanner [action] [option]"
          puts "    luna_scanner         -> Scan currnet LAN devices with default configuration"
          puts "    luna_scanner -ts 60  -> Set scan thread size to 60"
          puts "    luna_scanner reboot  -> Scan currnet LAN devices and reboot them"
          puts "    luna_scanner web     -> Start luna_scanner web ui on 4567 port"
          puts "    luna_scanner -v      -> Display luna_scanner version"
          puts "\n"
          puts opts
          exit 1
        end

        opts.on('-v', '--version', 'Display luna_scanner version.') do
          puts "luna_scanner v#{LunaScanner::VERSION}"
          exit 1
        end

      end.parse!

    end

    def execute
      if ARGV[0].to_s == ''
        LunaScanner::Scanner.scan!(:thread_size => @options[:t])
      elsif ARGV[0].to_s == 'reboot'
        LunaScanner::Scanner.scan!(:thread_size => @options[:t], :reboot => true)
      elsif ARGV[0].to_s == 'web'
        LunaScanner::Web.run!
      else
        puts "Invalid action / options"
        exit 1
      end
    end

    def self.start
      self.new.execute
    end
  end
end