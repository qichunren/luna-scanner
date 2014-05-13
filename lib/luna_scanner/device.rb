#encoding: utf-8
require 'csv'

module LunaScanner
  class Device
    attr_accessor :ip, :sn, :model, :dialno, :version, :to_change_ip
    IP_REGEX = /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/

    def initialize(options={})
      # ip, sn, model, version, to_change_ip=nil
      @ip      = options[:ip] || ""
      @sn      = options[:sn] || ""
      @model   = options[:model] || ""
      @version = options[:version] || ""
      @to_change_ip = options[:to_change_ip]
    end

    def self.display_header
      "-----SN--------IP-------------MODEL------VERSION------"
    end

    def ip_from_sn
      raise "SN not valid. 8 numbers." if self.sn !~ /^\d{8}$/

      sn_integer = self.sn.to_i
      if sn_integer % 250 == 0
        ip_3th_field = sn_integer/250 - 1
        ip_4th_field = 250
      else
        ip_3th_field = sn_integer/250
        ip_4th_field = sn_integer % 250
      end

      ip = "8.128.#{2+ip_3th_field}.#{ip_4th_field}"
      ip
    end

    def new_ip
      ip_template = <<TXT
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

#enable this if you are using 100Mbps
auto eth0
allow-hotplug eth0
iface eth0 inet static
address 0.0.0.0

auto eth1
allow-hotplug eth1
iface eth1 inet static
address #{ip_from_sn}
netmask 255.255.252.0
gateway 8.128.3.254
TXT
      ip_template
    end

    def write_ip_to_config
      File.open("/tmp/interfaces", "w") do |f|
        f.puts self.new_ip
      end
    end

    def display
      " #{sn}  #{ip.ljust(15)}  #{model.ljust(8)}  #{version}" # two space
    end

    def dev?
      sn.start_with?("f")
    end

    def ==(other)
      return false if not other.is_a?(Device)

      self.sn == other.sn
    end

    def self.load_from_file(file_name)
      if file_name && file_name.to_s.end_with?(".csv")
        self.validate_change_ip_csv_file!(file_name)

        devices = Array.new
        CSV.foreach(file_name) do |row|
          # sn,changed_ip
          devices << Device.new({
                                    :ip => nil, :sn => row[0], :model => nil, :version => nil, :to_change_ip => row[1]
                                })
        end
        return devices
      end

      ip_file = File.read(file_name)
      devices = Array.new

      ip_file.each_line do |ip_line|
        temp = ip_line.split(",")
        if temp.size < 5
          raise "ip file not valid, please check."
        end
      end

      ip_file.each_line do |ip_line|
        temp = ip_line.split(",")
        #f.puts "#{device.ip},#{device.sn},#{device.model},#{device.version},#{device.ip_from_sn}"
        devices << Device.new(:ip => temp[0], :sn => temp[1], :model => temp[2], :version => temp[3], :to_change_ip => temp[4]) if temp[1] && !temp[1].start_with?("f")
      end
      devices
    end

    def self.validate_change_ip_csv_file!(file_name)
      return false if file_name.nil? || !file_name.to_s.end_with?(".csv")

      changed_sn = Array.new
      changed_ip = Array.new
      CSV.foreach(file_name) do |row|
        abort "SN is blank!" if row[0].to_s.strip.length == 0
        abort "SN length in file #{file_name} should be 8" if row[0].to_s.strip.length != 8
        changed_sn << row[0].to_s.strip

        abort "IP is blank!" if row[1].to_s.strip.length == 0
        abort "IP #{row[1]} in file #{file_name} is an invalid ip string!" if row[1].to_s !~ IP_REGEX

        changed_ip << row[1].to_s.strip
      end

      if changed_sn.uniq.size != changed_sn.size
        abort "SN duplicated in file #{file_name}"
      end

      if changed_ip.uniq.size != changed_ip.size
        abort "IP duplicated in file #{file_name}"
      end
    end

  end
end