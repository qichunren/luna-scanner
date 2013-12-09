#encoding: utf-8
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

    def display
      "#{ip} #{sn} #{model}"
    end

    def dev?
      sn.start_with?("f")
    end

    def self.load_from_file(file)
      ip_file = File.read(file)
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