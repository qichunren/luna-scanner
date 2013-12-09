#encoding: utf-8

require 'erb'
require 'net/ssh'

module LunaScanner
  class Rcommand # mean remote command execute.

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
        Net::SSH.start(
            "#{connect_device.ip}", 'root',
            :auth_methods => ["publickey"],
            :user_known_hosts_file => "/dev/null",
            :timeout => 3,
            :keys => [ "#{LunaScanner.root}/keys/yu_pri" ]  # Fix key permission: chmod g-wr ./yu_pri  chmod o-wr ./yu_pri  chmod u-w ./yu_pri
        ) do |session|
          puts "Change #{connect_device.ip} (#{connect_device.sn}) to new ip #{new_ip}"
          session.exec!("echo '#{generated_ip}' > /etc/network/interfaces")
          session.exec!("reboot") if is_reboot
        end
      rescue
        Logger.error "              #{connect_device.ip} no response. #{$!.message}"
      end

    end

    def self.batch_change_ip(devices, options={})
      thread_pool = []
      options[:thread_size].to_i.times do
        ssh_thread = Thread.new do
          go = true
          while go
            device = devices.pop
            if device.nil?
              go = false
            else
              rcommand = self.new
              rcommand.change_ip(device, options[:is_reboot])
            end
          end
        end

        thread_pool << ssh_thread
      end

      thread_pool.each{|thread| thread.join }
    end

  end
end