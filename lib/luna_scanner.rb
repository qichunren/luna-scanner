require 'socket'
require 'net/ssh'
require "luna_scanner/version"

module LunaScanner

  class SSHKeyNotFoundError < StandardError; end

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

    def ssh_key
      @ssh_key ||= Dir.home.to_s + "/yu_pri" # Dir.home method is not in Ruby 1.8
    end

    def check_ssh_key!
      raise SSHKeyNotFoundError.new("Please provide ssh key file: #{ssh_key}") if not File.exist?(ssh_key)

      ssh_key
    end

    def start_ssh(ip, &block)
      Net::SSH.start(
          "#{ip}", 'root',
          :auth_methods => ["publickey"],
          :user_known_hosts_file => "/dev/null",
          :timeout => 8,
          :verbose => :error,
          :keys => [ ssh_key ]  # Fix key permission: chmod g-wr ./yu_pri  chmod o-wr ./yu_pri  chmod u-w ./yu_pri
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
