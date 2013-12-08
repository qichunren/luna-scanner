module LunaScanner
  class CLI

    def initialize()

    end

    def execute
      puts ARGV.inspect
    end

    def self.start
      self.new.start
    end
  end
end