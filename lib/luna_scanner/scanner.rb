require 'socket'
require 'net/ssh'

module LunaScanner
  class Scanner

    @@found_devices = Array.new

    def initialize(thread_size, start_ip, end_ip)
      raise "thread pool size not correct!" if thread_size.to_i <= 0
      @thread_size = thread_size.to_i
      Logger.info "Local ip #{LunaScanner.local_ip}"

      @scan_ip_range = Util.ip_range(start_ip, end_ip)
    end

    def generate_ip_range(options)
      if options[:input_ip].to_s.length > 0 # get ip range from file
        raise "IP input file not exist." if !File.exist?(options[:input_ip])


      else                                  # get ip range from start_ip to end_ip
        if options[:start_ip].to_s.length == 0 || options[:end_ip].to_s.length == 0
          raise "Require arguments to get ip range"
        end


      end

    end

    def scan(is_reboot, shell_command)
      thread_pool = []
      @scan_ip_range.reverse!
      @thread_size.times do
        ssh_thread = Thread.new do
          go = true
          while go
            ip = @scan_ip_range.pop
            if ip.nil?
              go = false
            else
              begin
                Logger.info "Scan ip #{ip} ..."
                LunaScanner.start_ssh(ip) do |shell|
                  sn      = shell.exec!('cat /proc/itc_sn/sn').chomp
                  model   = shell.exec!('cat /proc/itc_sn/model').chomp
                  version = shell.exec!('cat /jenkins_version.txt').chomp

                  if shell_command.to_s.length > 0
                    Logger.info "        execute command: #{shell_command} ...", :time => false
                    shell.exec!("#{shell_command}")
                  end

                  if sn != "cat: /proc/itc_sn/sn: No such file or directory"
                    @@found_devices << Device.new(ip, sn, model, version)
                    Logger.success "                   #{ip} #{sn} #{model} #{version}", :time => false
                    shell.exec!("reboot") if is_reboot
                  end
                end
              rescue
                      Logger.error "                   #{ip} no response. #{$!.message}", :time => false
              end
            end
          end
        end

        thread_pool << ssh_thread
      end

      thread_pool.each{|thread| thread.join }
    end

    def self.scan!(options={})
      start_ip = options[:start_ip] || Util.begin_ip(LunaScanner.local_ip)
      end_ip   = options[:end_ip] || Util.end_ip(LunaScanner.local_ip)
      scanner = self.new(options[:thread_size], start_ip, end_ip)

      Logger.info "Start scan from #{start_ip} to #{end_ip} #{options[:reboot] ? '(reboot)' : ''} ..."
      scanner.scan(options[:reboot], options[:command])

      Logger.info "\n#{Device.display_header}", :time => false
      @@found_devices.each do |device|
        Logger.success device.display, :time => false
      end
      Logger.info "\n#{@@found_devices.size} devices found. #{options[:reboot] ? '(reboot)' : ''}", :time => false
      if options[:result]
        begin
          File.open(options[:result], "w") do |f|
            @@found_devices.each do |device|
              f.puts "#{device.ip.rjust(15)} #{device.sn} #{device.model.rjust(10)} #{device.version.rjust(13)}"
            end
          end
        rescue
          Logger.error "Failed to write scan result to #{options[:result]}", :time => false
        else
          Logger.error "Write scan result to #{options[:result]}", :time => false
        end
      end
      Logger.info "\n", :time => false
    end

    def self.upload!(source_file, target_file, options={}, &block)
      require 'net/scp'
      if options[:input_ip] # Scan from given input ip file.
        source_devices = File.read(options[:input_ip])
        upload_hosts = Array.new
        source_devices.each_line do |device|
          ip,sn,model,version = device.split(" ")
          upload_hosts << ip
        end
        upload_hosts.uniq!

        return if upload_hosts.size == 0

        thread_pool = []
        options[:thread_size].times do
          ssh_thread = Thread.new do
            go = true
            while go
              ip = upload_hosts.pop
              if ip.nil?
                go = false
              else
                begin
                  Logger.info "Connect to ip #{ip} ..."
                  LunaScanner.start_ssh(ip) do |shell|
                    Logger.info "         upload file #{source_file} to #{ip} #{target_file}", :time => false
                    shell.scp.upload!(source_file, target_file)
                    block.call(shell) if block
                  end
                rescue
                  Logger.error "             #{ip} not connected. #{$!.message}"
                end
              end
            end
          end

          thread_pool << ssh_thread
        end

        thread_pool.each{|thread| thread.join }

      else
        # self.scan!(options)
        puts "Not implement yet."
        exit 4
      end
    end

    def self.found_devices
      @@found_devices
    end

  end
end