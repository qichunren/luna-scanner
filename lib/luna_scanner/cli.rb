#encoding: utf-8
require 'optparse'

module LunaScanner
  class CLI

    def initialize()
      @options = {
          :thread_size => 50,
          :reboot      => false,
          :result      => nil,
          :start_ip    => nil,
          :end_ip      => nil,
          :source_file => nil,
          :target_file => nil,
          :input_ip => nil,
          :command => ""
      }
      option_parser = OptionParser.new do |opts|
        opts.banner = 'Luna Scanner toolkit.'

        opts.on('-t', '--thread_size COUNT', 'Set luna_scanner scan thread size.') do |thread_size|
          @options[:thread_size] = thread_size.to_i
        end

        # TODO include extra ip, exclude extra ip from --ip_range option
        opts.on('--ip_range START_IP,END_IP', 'Set luna_scanner scan ip range.') do |ip_param|
          ip_range = ip_param.split(",")
          @options[:start_ip] = ip_range[0]
          @options[:end_ip]   = ip_range[1]
        end

        opts.on('-i', '--input INPUT_IP', 'Scan from given INPUT_IP file.') do |file|
          #TODO fixed path string, such as ~ or ./
          if file && file.start_with?("/")
            @options[:input_ip] = file
          else
            @options[:input_ip] = LunaScanner.pwd + "/" + file
          end
        end

        opts.on('-r', '--result RESULT_FILE', 'Store scan result to file.') do |result_file|
          #TODO fixed path string, such as ~ or ./
          if result_file && result_file.start_with?("/")
            @options[:result] = result_file
          else
            @options[:result] = LunaScanner.pwd + "/" + result_file
          end
        end

        opts.on('--reboot', 'Reboot devices.') do
          @options[:reboot] = true
        end

        opts.on('--source_file SOURCE_FILE', 'Source file to upload to remote. Only be used for [upload] action') do |file|
          #TODO fixed path string, such as ~ or ./
          if file && file.start_with?("/")
            @options[:source_file] = file
          else
            @options[:source_file] = LunaScanner.pwd + "/" + file
          end
        end

        opts.on('--target_file TARGET_FILE', 'File to upload to target place. Only be used for [upload] action') do |file|
          if file && file.start_with?("/")
            @options[:target_file] = file
          else
            puts "--target_file option value must start with / absolute path"
            exit 1
          end
        end

        opts.on('-c', '--command SHELL_COMMAND', 'Shell command execute on remote devices. Only be used for [upload] action') do |command_string|
          @options[:command] = command_string
        end

        opts.on_tail("-h", "--help", "luna_scanner usage.") do
          puts "Luna Scanner usage:"
          puts "  luna_scanner [action] [option]"
          puts "    luna_scanner                                                 -> Scan currnet LAN devices with default configuration"
          puts "    luna_scanner -t 60                                           -> Set scan thread size to 60"
          puts "    luna_scanner change_ip                                       -> Batch change LAN devices ip configuration"
          puts "    luna_scanner upload --source_file file1 --target_file file2  -> Upload file1 to file2 on LAN devices"
          puts "    luna_scanner web                                             -> Start luna_scanner web ui on 4567 port (To be done)"
          puts "    luna_scanner -v                                              -> Display luna_scanner version"
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
        LunaScanner.check_ssh_key!
        LunaScanner::Scanner.scan!(@options)
      elsif ARGV[0].to_s == 'reboot'
        LunaScanner.check_ssh_key!
        @options[:reboot] = true
        LunaScanner::Scanner.scan!(@options)
      elsif ARGV[0].to_s == 'upload'
        LunaScanner.check_ssh_key!
        source_file = @options.delete(:source_file)
        target_file = @options.delete(:target_file)
        if source_file.nil? || target_file.nil?
          puts "--source_file SOURCE_FILE or --target_file TARGET_FILE options missing for upload action."
          exit 1
        end
        if !File.exist?(source_file)
          puts "Source file #{source_file} not exist."
          exit 2
        end
        if @options[:input_ip] && !File.exist?(@options[:input_ip])
          puts "Input ip file #{@options[:input_ip]} not exist."
          exit 3
        end

        LunaScanner::Scanner.upload!(source_file, target_file, @options) do |shell|
          shell.exec!(@options[:command]) if @options[:command].length > 0
        end
      elsif ARGV[0].to_s == 'web'
        LunaScanner::Web.run!
      elsif ARGV[0].to_s == 'change_ip'
        LunaScanner.check_ssh_key!

        if @options[:input_ip] && !File.exist?(@options[:input_ip])
          puts "Input ip file #{@options[:input_ip]} not exist."
          exit 3
        end

        devices = Device.load_from_file(@options[:input_ip])
        LunaScanner::Rcommand.batch_change_ip(devices, @options)

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