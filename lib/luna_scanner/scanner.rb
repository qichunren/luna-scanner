require 'socket'
require 'net/ssh'

module LunaScanner
  class Scanner

    @@found_devices = Array.new

    def initialize(thread_size, start_ip, end_ip)
      raise "thread pool size not correct!" if thread_size.to_i <= 0
      @thread_size = thread_size.to_i
      puts "Local ip #{LunaScanner.local_ip}"

      @scan_ip_range = ip_source(start_ip, end_ip)
    end

    def start_ssh(ip, &block)
      Net::SSH.start(
          "#{ip}", 'root',
          :auth_methods => ["publickey"],
          :user_known_hosts_file => "/dev/null",
          :timeout => 3,
          :keys => [ "#{root}/keys/yu_pri" ]  # Fix key permission: chmod g-wr ./yu_pri  chmod o-wr ./yu_pri  chmod u-w ./yu_pri
      ) do |session|
        block.call(session)
      end
    end

    # 192.169.3.1
    # 192.168.5.222
    def ip_source(start_ip, end_ip)
      start_ip_array = start_ip.split(".")
      end_ip_array = end_ip.split(".")
      raise "IP not valid." if start_ip_array.size != 4 || end_ip_array.size != 4
      raise "IP not valid." if start_ip_array[3].to_i > 255 || end_ip_array[3].to_i > 255
      raise "Start ip and end ip must be in same range." if start_ip_array[0] != end_ip_array[0] || start_ip_array[1] != end_ip_array[1]
      raise "IP range not valid" if start_ip_array[2].to_i > end_ip_array[2].to_i
      raise "IP range not valid" if (start_ip_array[2].to_i == end_ip_array[2].to_i) && start_ip_array[3].to_i >= end_ip_array[3].to_i

      ip_array = []
      if start_ip_array[2].to_i == end_ip_array[2].to_i # 192.168.1.1 ~ 192.168.1.10
        (start_ip_array[3].to_i..end_ip_array[3].to_i).step do |i|
          ip_array << start_ip_array[0] + "." + start_ip_array[1] + "." + start_ip_array[2] + ".#{i}"
        end
      else # 192.168.1.1 ~ 192.168.3.10
        (start_ip_array[2].to_i..end_ip_array[2].to_i).step do |i|
          if start_ip_array[2].to_i == i
            (start_ip_array[3].to_i..254).step do |j|
              ip_array << start_ip_array[0] + "." + start_ip_array[1] + "." + start_ip_array[2] + ".#{j}"
            end
          elsif end_ip_array[2].to_i == i
            (2..end_ip_array[3].to_i).step do |j|
              ip_array << start_ip_array[0] + "." + start_ip_array[1] + "." + end_ip_array[2] + ".#{j}"
            end
          else
            (2..254).step do |j|
              ip_array << start_ip_array[0] + "." + start_ip_array[1] + ".#{i}.#{j}"
            end
          end
        end
      end

      ip_array
    end

    def scan
      thread_pool = []
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
                    @@found_devices << Device.new(ip, sn, model)
                    puts "#{ip} #{sn} #{model} #{version}"
                  end
                end
              rescue
                Logger.error "                   #{ip} no response.", :time => false
              end
            end
          end
        end

        thread_pool << ssh_thread
      end

      thread_pool.each{|thread| thread.join }
    end

    def self.scan!(start_ip=nil, end_ip=nil)
      if start_ip.nil?
        start_ip = Util.begin_ip(LunaScanner.local_ip)
      end
      if end_ip.nil?
        end_ip = Util.end_ip(LunaScanner.local_ip)
      end
      scanner = self.new(1, start_ip, end_ip)

      Logger.info "Start scan from #{start_ip} to #{end_ip} ..."
      scanner.scan

      Logger.info "#{@@found_devices.size} devices found.", :time => false
    end


  end
end