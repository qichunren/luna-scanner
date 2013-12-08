require "sinatra/base"

module LunaScanner
  class Web < Sinatra::Base
    not_found do
      "Sir, I don't understand what you mean."
    end

    get '/' do
      "luna_scanner"
    end

  end
end