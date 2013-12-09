#encoding: utf-8
require 'optparse'
require "futils"

module LunaScanner
  class CLI

    def initialize()
      @options = {
          :thread_size => 50,
          :reboot      => false,
          :result      => nil,
          :start_ip    => nil,
          :end_ip      => nil
      }
      option_parser = OptionParser.new do |opts|
        opts.banner = 'Luna Scanner toolkit.'

        opts.on('-t', '--thread_size COUNT', 'Set luna_scanner scan thread size.') do |thread_size|
          @options[:thread_size] = thread_size.to_i
        end

        # TODO include extra ip, exclude extra ip from --ip_range option
        opts.on('--ip_range start_ip,end_ip', 'Set luna_scanner scan ip range.') do |ip_range|
          @options[:start_ip] = ip_range[0]
          @options[:end_ip]   = ip_range[1]
        end

        opts.on('-r', '--result RESULT_FILE', 'Store scan result to file.') do |result_file|
          if result_file && result_file.start_with?("/")
            @options[:result] = result_file
          else
            @options[:result] = result_file
          end
        end

        opts.on_tail("-h", "--help", "luna_scanner usage.") do
          puts Dir.pwd
          puts "Luna Scanner usage:"
          puts "  luna_scanner [action] [option]"
          puts "    luna_scanner         -> Scan currnet LAN devices with default configuration"
          puts "    luna_scanner -ts 60  -> Set scan thread size to 60"
          puts "    luna_scanner reboot  -> Scan currnet LAN devices and reboot them"
          puts "    luna_scanner upload  -> Upload file to LAN devices"
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
        LunaScanner::Scanner.scan!(@options)
      elsif ARGV[0].to_s == 'reboot'
        @options[:reboot] = true
        LunaScanner::Scanner.scan!(@options)
      elsif ARGV[0].to_s == 'upload'
        #TODO

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