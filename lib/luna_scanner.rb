require 'socket'
require 'net/ssh'
require "luna_scanner/version"

module LunaScanner
  class << self
    def root
      @root_path ||= File.expand_path("../", __FILE__)
    end

    def pwd
      @pwd ||= Dir.pwd
    end

    def local_ip
      @local_ip ||= begin
        orig = Socket.do_not_reverse_lookup
        Socket.do_not_reverse_lookup =true # turn off reverse DNS resolution temporarily
        UDPSocket.open do |s|
          s.connect '64.233.187.99', 1 #google
          s.addr.last
        end
      rescue

      ensure
        Socket.do_not_reverse_lookup = orig
      end
    end

    def start_ssh(ip, &block)
      Net::SSH.start(
          "#{ip}", 'root',
          :auth_methods => ["publickey"],
          :user_known_hosts_file => "/dev/null",
          :timeout => 3,
          :keys => [ "#{LunaScanner.root}/keys/yu_pri" ]  # Fix key permission: chmod g-wr ./yu_pri  chmod o-wr ./yu_pri  chmod u-w ./yu_pri
      ) do |session|
        block.call(session)
      end
    end


  end
end

LunaScanner.autoload :Logger,   "luna_scanner/logger"
LunaScanner.autoload :Device,   "luna_scanner/device"
LunaScanner.autoload :Util,     "luna_scanner/util"
LunaScanner.autoload :CLI,      "luna_scanner/cli"
LunaScanner.autoload :Rcommand, "luna_scanner/rcommand"
LunaScanner.autoload :Scanner,  "luna_scanner/scanner"
LunaScanner.autoload :Web,      "luna_scanner/web"
