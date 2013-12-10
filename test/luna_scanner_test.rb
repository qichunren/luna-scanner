require File.expand_path("../test_helper", __FILE__)

describe LunaScanner do

  it "root must be defined" do
    LunaScanner.root.wont_be_nil
  end

  it "pwd must be defined" do
    LunaScanner.pwd.wont_be_nil
  end

  it "local_ip must be defined" do
    LunaScanner.local_ip.wont_be_nil
  end

  it "version must be defined" do
    LunaScanner::VERSION.wont_be_nil
  end

end