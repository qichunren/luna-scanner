module LunaScanner
  class Util
    class << self
      def begin_ip(ip)
        ip_array = ip.to_s.split(".")
        raise "IP Error." if ip_array.size != 4

        "#{ip_array[0]}.#{ip_array[1]}.#{ip_array[2]}.1"
      end

      def end_ip(ip)
        ip_array = ip.to_s.split(".")
        raise "IP Error." if ip_array.size != 4

        "#{ip_array[0]}.#{ip_array[1]}.#{ip_array[2]}.255"
      end
    end
  end
end