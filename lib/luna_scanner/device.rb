#encoding: utf-8
module LunaScanner
  class Device
    attr_accessor :ip, :sn, :model, :dialno, :version
    def initialize(ip, sn, model)
      @ip = ip
      @sn = sn
      @model = model
    end

    def display
      "#{ip} #{sn} #{model}"
    end

    def dev?
      sn.start_with?("f")
    end

  end
end