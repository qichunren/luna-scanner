require "luna_scanner/version"

module LunaScanner
  class << self
    def root
      @root_path ||= File.expand_path("../", __FILE__)
    end
  end
end

LunaScanner.autoload :CLI,     "luna_scanner/cli"
LunaScanner.autoload :Scanner, "luna_scanner/scanner"
LunaScanner.autoload :Web,     "luna_scanner/web"
