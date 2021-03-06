#encoding: utf-8

require 'erb'
require 'net/ssh'
require 'net/scp'

module LunaScanner
  class Rcommand # mean remote command execute.

    @@ip_max_length = 7 #1.1.1.1
    @@total_devices_count = 0
    @@success_devices_count = 0

    def reboot!(ip)
      return false if ip.nil?

      Logger.info "Try to reboot #{ip} ..."
      begin
        Net::SSH.start(
            "#{ip}", 'root',
            :auth_methods => ["publickey"],
            :user_known_hosts_file => "/dev/null",
            :timeout => 3,
            :keys => [ "#{LunaScanner.root}/keys/yu_pri" ]  # Fix key permission: chmod g-wr ./yu_pri  chmod o-wr ./yu_pri  chmod u-w ./yu_pri
        ) do |session|
          session.exec!("reboot")
        end
      rescue
        Logger.error "              #{ip} no response. #{$!.message}"
      end
    end

    def change_ip(connect_device, is_reboot)
      if connect_device.ip == ''
        Logger.error "Device #{connect_device.sn} not found in LAN."
        return false
      end

      begin
        LunaScanner.start_ssh(connect_device.ip) do |shell|
          Logger.info "Changed device #{connect_device.sn} [#{connect_device.ip.ljust(@@ip_max_length)}] to new ip #{connect_device.to_change_ip.ljust(15)}"
          shell.exec!("echo '#{connect_device.new_ip}' > /etc/network/interfaces")
          shell.exec!("reboot") if is_reboot
        end
      rescue
        Logger.error "Failed to change device #{connect_device.sn} to new ip #{connect_device.new_ip.ljust(15)} #Error reason: #{$!.message}"
        return false
      else
        return true
      end
    end

    def self.batch_change_ip(options={})
      target_devices = Device.load_from_file(options[:input_ip])
      @@total_devices_count = target_devices.size

      Logger.info "->  Start batch change ip.", :time => false

      thread_pool = []
      10.times do
        ssh_thread = Thread.new do
          go = true
          while go
            device = target_devices.pop
            if device.nil?
              go = false
            else
              rcommand = self.new
              if rcommand.change_ip(device, options[:reboot])
                @@success_devices_count += 1
              end
            end
          end
        end

        thread_pool << ssh_thread
      end

      thread_pool.each{|thread| thread.join }

      Logger.info "\n#{@@success_devices_count}/#{@@total_devices_count} devices changed.", :time => false
      Logger.info "Restart all devices to make changes work.", :time => false if !options[:reboot]
    end

    def self.batch_update(options={})
      update_script_file = File.expand_path("../update_firmware.sh", __FILE__)
      target_devices = Device.load_from_file(options[:input_ip])
      Logger.info "->  Start batch update.", :time => false

      thread_pool = []
      10.times do
        ssh_thread = Thread.new do
          go = true
          while go
            device = target_devices.pop
            if device.nil?
              go = false
            else
              begin

                    Logger.info "->  Update #{device.ip} #{device.sn}"
                    LunaScanner.start_ssh(device.ip) do |shell|
                      shell.scp.upload!("#{update_script_file}", "/usr/local/luna-client/script/update_firmware.sh")
                      shell.exec!("chmod a+x /usr/local/luna-client/script/update_firmware.sh")
                      shell.exec!("sed -i 's/iface eth0 inet dhcp/iface eth0 inet static\naddress 0.0.0.0/' /etc/network/interfaces")
                      shell.exec!("/usr/local/luna-client/script/update_firmware.sh http://8.128.3.254 1500k")
                    end


              rescue
                Logger.error "Failed to update device #{device.sn} #{device.ip}  #{$!.message}"
               # return false
              else
               # return true
              end
            end
          end
        end

        thread_pool << ssh_thread
      end

      thread_pool.each{|thread| thread.join }

    end

  end
end