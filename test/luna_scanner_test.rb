require File.expand_path("../test_helper", __FILE__)

puts LunaScanner.local_ip

puts LunaScanner::Scanner.scan!