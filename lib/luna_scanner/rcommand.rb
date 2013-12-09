#encoding: utf-8
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
  end
end