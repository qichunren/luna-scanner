#encoding: utf-8

require 'erb'
require 'net/ssh'

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

      new_ip = connect_device.to_change_ip
      ip_template = <<TXT

# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

#enable this if you are using 100Mbps
auto eth0
allow-hotplug eth0
iface eth0 inet dhcp

auto eth1
allow-hotplug eth1
iface eth1 inet static
address <%= new_ip %>
netmask 255.255.252.0
gateway 192.168.1.1
dns-nameservers 192.168.1.1
TXT
      renderer = ERB.new(ip_template)
      generated_ip = renderer.result(binding)

      begin
        LunaScanner.start_ssh(connect_device.ip) do |shell|
          Logger.info "Changed device #{connect_device.sn} [#{connect_device.ip.ljust(@@ip_max_length)}] to new ip #{new_ip.ljust(15)}"
          session.exec!("echo '#{generated_ip}' > /etc/network/interfaces")
          session.exec!("reboot") if is_reboot
        end
      rescue
        Logger.error "Failed to change device #{connect_device.sn} to new ip #{new_ip.ljust(15)} #Error reason: #{$!.message}"
        return false
      else
        return true
      end
    end

    def self.batch_change_ip(options={})
      target_devices = Device.load_from_file(options[:input_ip])
      @@total_devices_count = target_devices.size

      LunaScanner::Scanner.scan!(options)
      found_devices = LunaScanner::Scanner.found_devices

      Logger.info "->  Start batch change ip.", :time => false

      target_devices.each do |target_device|
        scanned_device =  found_devices.detect{|device| device == target_device }
        if scanned_device
          target_device.ip = scanned_device.ip
        end
        @@ip_max_length = target_device.ip.length if @@ip_max_length < target_device.ip.length
      end

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

  end
end