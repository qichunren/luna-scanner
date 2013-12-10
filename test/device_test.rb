require File.expand_path("../test_helper", __FILE__)

describe LunaScanner::Device do
  it "must have load_from_file method" do
    LunaScanner::Device.must_respond_to(:load_from_file)
  end

  it "must be initialized with given attributes" do
    device = LunaScanner::Device.new("192.168.1.22", "00001234", "T-7202D", "20131212.121212")
    device.ip.must_equal("192.168.1.22")
    device.sn.must_equal("00001234")
    device.model.must_equal("T-7202D")
    device.version.must_equal("20131212.121212")
  end

  it "must be format when display" do
    device1 = LunaScanner::Device.new("192.168.1.22", "00001234", "T-7202D", "20131212.121212")
    device2 = LunaScanner::Device.new("192.168.1.1", "00001234", "T-7202D", "20131212.121212")
    device3 = LunaScanner::Device.new("192.168.111.111", "00001234", "T-7202D", "20131212.121212")
    device4 = LunaScanner::Device.new("192.168.111.2", "00001234", "T-7202", "20131212.121212")
    device5 = LunaScanner::Device.new("192.168.10.2", "00001234", "T-720", "20131212.121212")
    device6 = LunaScanner::Device.new("192.168.10.21", "00001234", "T-72011D", "20131212.121212")

    ########################## "-----IP-------------SN-------MODEL------VERSION-------"
    device1.display.must_equal(" 192.168.1.22     00001234  T-7202D   20131212.121212")
    device2.display.must_equal(" 192.168.1.1      00001234  T-7202D   20131212.121212")
    device3.display.must_equal(" 192.168.111.111  00001234  T-7202D   20131212.121212")
    device4.display.must_equal(" 192.168.111.2    00001234  T-7202    20131212.121212")
    device5.display.must_equal(" 192.168.10.2     00001234  T-720     20131212.121212")
    device6.display.must_equal(" 192.168.10.21    00001234  T-72011D  20131212.121212")

  end

end