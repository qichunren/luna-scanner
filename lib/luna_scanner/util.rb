module LunaScanner
  class Util
    class << self

      def ip_valid?(ip)
        ip_array = ip.to_s.split(".")
        return false if ip_array.size != 4

        return false if ip_array[3].to_i <= 0 || ip_array[3].to_i > 255

        true
      end

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

      def ip_range(begin_ip, end_ip)
        start_ip_array = begin_ip.split(".")
        end_ip_array = end_ip.split(".")
        raise "IP not valid." if start_ip_array.size != 4 || end_ip_array.size != 4
        raise "IP not valid." if start_ip_array[3].to_i > 255 || end_ip_array[3].to_i > 255
        raise "Start ip and end ip must be in same range." if start_ip_array[0] != end_ip_array[0] || start_ip_array[1] != end_ip_array[1]
        raise "IP range not valid" if start_ip_array[2].to_i > end_ip_array[2].to_i
        raise "IP range not valid" if (start_ip_array[2].to_i == end_ip_array[2].to_i) && start_ip_array[3].to_i > end_ip_array[3].to_i

        ip_array = []
        if start_ip_array[2].to_i == end_ip_array[2].to_i # 192.168.1.1 ~ 192.168.1.10
          (start_ip_array[3].to_i..end_ip_array[3].to_i).step do |i|
            ip_array << start_ip_array[0] + "." + start_ip_array[1] + "." + start_ip_array[2] + ".#{i}"
          end
        else # 192.168.1.1 ~ 192.168.3.10
          (start_ip_array[2].to_i..end_ip_array[2].to_i).step do |i|
            if start_ip_array[2].to_i == i
              (start_ip_array[3].to_i..255).step do |j|
                ip_array << start_ip_array[0] + "." + start_ip_array[1] + "." + start_ip_array[2] + ".#{j}"
              end
            elsif end_ip_array[2].to_i == i
              (1..end_ip_array[3].to_i).step do |j|
                ip_array << start_ip_array[0] + "." + start_ip_array[1] + "." + end_ip_array[2] + ".#{j}"
              end
            else
              (1..255).step do |j|
                ip_array << start_ip_array[0] + "." + start_ip_array[1] + ".#{i}.#{j}"
              end
            end
          end
        end

        ip_array
      end
    end
  end
end