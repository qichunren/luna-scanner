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

    def scan(is_reboot)
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
      scanner.scan(options[:reboot])

      Logger.info "\n-----IP----------SN-----------MODEL------VERSION-----", :time => false
      @@found_devices.each do |device|
        Logger.success "#{device.ip.rjust(15)} #{device.sn} #{device.model.rjust(10)} #{device.version.rjust(14)}", :time => false
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
        source_devices.each_line do |device|
          ip,sn,model,version = device.split(" ")
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
      else
        # self.scan!(options)
        puts "Not implement yet."
        exit 4
      end
    end


  end
end