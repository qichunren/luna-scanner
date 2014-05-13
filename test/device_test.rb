require File.expand_path("../test_helper", __FILE__)

describe LunaScanner::Device do
  it "must have load_from_file method" do
    LunaScanner::Device.must_respond_to(:load_from_file)
  end

  it "must be initialized with given attributes" do
    device = LunaScanner::Device.new(:ip => "192.168.1.22", :sn => "00001234", :model => "T-7202D", :version => "20131212.121212")
    device.ip.must_equal("192.168.1.22")
    device.sn.must_equal("00001234")
    device.model.must_equal("T-7202D")
    device.version.must_equal("20131212.121212")
  end

  it "must be format when display" do
    device1 = LunaScanner::Device.new(:ip => "192.168.1.22", :sn => "00001234", :model => "T-7202D", :version => "20131212.121212")
    device2 = LunaScanner::Device.new(:ip => "192.168.1.1", :sn => "00001234", :model => "T-7202D", :version => "20131212.121212")
    device3 = LunaScanner::Device.new(:ip => "192.168.111.111", :sn => "00001234", :model => "T-7202D", :version => "20131212.121212")
    device4 = LunaScanner::Device.new(:ip => "192.168.111.2", :sn => "00001234", :model => "T-7202", :version => "20131212.121212")
    device5 = LunaScanner::Device.new(:ip => "192.168.10.2", :sn => "00001234", :model => "T-720", :version => "20131212.121212")
    device6 = LunaScanner::Device.new(:ip =>  "192.168.10.21", :sn => "00001234", :model => "T-72011D", :version => "20131212.121212")

    ########################## "----SN---------IP------------MODEL------VERSION--------"
    device1.display.must_equal(" 00001234  192.168.1.22     T-7202D   20131212.121212")
    device2.display.must_equal(" 00001234  192.168.1.1      T-7202D   20131212.121212")
    device3.display.must_equal(" 00001234  192.168.111.111  T-7202D   20131212.121212")
    device4.display.must_equal(" 00001234  192.168.111.2    T-7202    20131212.121212")
    device5.display.must_equal(" 00001234  192.168.10.2     T-720     20131212.121212")
    device6.display.must_equal(" 00001234  192.168.10.21    T-72011D  20131212.121212")

  end

  it "should generate new ip from sn" do
    device1 = LunaScanner::Device.new(:ip => "192.168.1.22", :sn => "", :model => "T-7202D", :version => "20131212.121212")
    { "00000001" => "8.128.2.1",
      "00000002" => "8.128.2.2",
      "00000003" => "8.128.2.3",
      "00000004" => "8.128.2.4",
      "00000005" => "8.128.2.5",
      "00000010" => "8.128.2.10",
      "00000100" => "8.128.2.100",
      "00000101" => "8.128.2.101",
      "00000200" => "8.128.2.200",
      "00000201" => "8.128.2.201",
      "00000240" => "8.128.2.240",
      "00000249" => "8.128.2.249",
      "00000250" => "8.128.2.250",
      "00000251" => "8.128.3.1",
      "00000252" => "8.128.3.2",
      "00000253" => "8.128.3.3",
      "00000254" => "8.128.3.4",
      "00000255" => "8.128.3.5",
      "00000499" => "8.128.3.249",
      "00000500" => "8.128.3.250",
      "00000501" => "8.128.4.1"
    }.each do |sn, ip|
      device1.sn = sn; device1.ip_from_sn.must_equal(ip)
      end
  end

  it "should generate ip file" do
    device1 = LunaScanner::Device.new(:ip => "192.168.1.22", :sn => "00000034", :model => "T-7202D", :version => "20131212.121212")
    device1.new_ip.must_equal("# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

#enable this if you are using 100Mbps
auto eth0
allow-hotplug eth0
iface eth0 inet static
address 0.0.0.0

auto eth1
allow-hotplug eth1
iface eth1 inet static
address 8.128.2.34
netmask 255.255.252.0
gateway 8.128.3.254
")

    device2 = LunaScanner::Device.new(:ip => "192.168.1.22", :sn => "00000034", :model => "T-7202D", :version => "20131212.121212")
    `echo '#{device2.new_ip}' > /tmp/interfaces0`
  end

  it "should write ip config file" do
    device1 = LunaScanner::Device.new(:ip => "192.168.1.22", :sn => "00000034", :model => "T-7202D", :version => "20131212.121212")
    device1.write_ip_to_config
    File.exist?("/tmp/interfaces").must_equal true
  end

end