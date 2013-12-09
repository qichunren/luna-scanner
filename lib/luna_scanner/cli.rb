#encoding: utf-8
require 'optparse'

module LunaScanner
  class CLI

    def initialize()
      @options = {}
      option_parser = OptionParser.new do |opts|
        opts.banner = 'Luna Scanner toolkit.'

        @options[:ts] = 50
        opts.on('-ts', '--thread_size COUNT', 'Set luna_scanner scan thread size.') do |thread_size|
          @options[:ts] = thread_size.to_i
        end

        opts.on_tail("-h", "--help", "luna_scanner usage.") do
          puts "Help message."
          puts "  * item 1"
          puts "  * item 2"
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
      if ARGV[0].to_s == '' || ARGV[0].to_s == 'scan'
        LunaScanner::Scanner.scan!(:thread_size => @options[:ts])
      elsif ARGV[0].to_s == 'web'
        LunaScanner::Web.run!
      end
    end

    def self.start
      self.new.execute
    end
  end
end