#encoding: utf-8
require 'csv'

module LunaScanner
  class Device
    attr_accessor :ip, :sn, :model, :dialno, :version, :to_change_ip
    def initialize(ip, sn, model, version, to_change_ip=nil)
      @ip      = ip || ""
      @sn      = sn || ""
      @model   = model || ""
      @version = version || ""
      @to_change_ip = to_change_ip
    end

    def self.display_header
      "-----SN--------IP-------------MODEL------VERSION------"
    end

    def display
      " #{sn}  #{ip.ljust(15)}  #{model.ljust(8)}  #{version}" # two space
    end

    def dev?
      sn.start_with?("f")
    end

    def eql?(other)
      return false if other.is_a?(Device)

      self.sn.to_s == other.sn.to_s
    end

    def self.load_from_file(file_name)
      if file_name && file_name.to_s.end_with?(".csv")
        devices = Array.new
        CSV.foreach(file_name) do |row|
          devices << Device.new(nil, row[0], nil, nil, row[1])
        end
        return devices
      end

      ip_file = File.read(file_name)
      devices = Array.new

      ip_file.each_line do |ip_line|
        temp = ip_line.split(" ")
        if temp.size < 5
          raise "ip file not valid, please check."
        end
      end

      ip_file.each_line do |ip_line|
        temp = ip_line.split(" ")

        devices << Device.new(temp[0], temp[1], temp[2], temp[3], temp[4]) if temp[1] && !temp[1].start_with?("f")
      end
      devices
    end

  end
end