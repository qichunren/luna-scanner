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

    def start_ssh(ip, &block)
      Net::SSH.start(
          "#{ip}", 'root',
          :auth_methods => ["publickey"],
          :user_known_hosts_file => "/dev/null",
          :timeout => 3,
          :keys => [ "#{LunaScanner.root}/keys/yu_pri" ]  # Fix key permission: chmod g-wr ./yu_pri  chmod o-wr ./yu_pri  chmod u-w ./yu_pri
      ) do |session|
        block.call(session)
      end
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
                start_ssh(ip) do |shell|
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

      Logger.info "#{@@found_devices.size} devices found. #{options[:reboot] ? '(reboot)' : ''}", :time => false
      Logger.info "\n-----SN-------------IP----------MODEL------VERSION-----", :time => false
      @@found_devices.each do |device|
        Logger.success "  #{device.sn} #{device.ip.rjust(15)} #{device.model.rjust(10)}   #{device.version.rjust(14)}", :time => false
      end
      Logger.info "\n", :time => false
    end


  end
end