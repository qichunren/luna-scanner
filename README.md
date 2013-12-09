# LunaScanner

TODO: Write a gem description

## Installation

execute:
./INSTALL

or

Add this line to your application's Gemfile:

    gem 'luna_scanner'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install luna_scanner

## Usage

    luna_scanner
    luna_scanner reboot
    luna_scanner --ip_range=192.168.0.1,192.168.4.255 -r 192_ip.txt
    luna_scanner change_ip -i 10_ip.txt
    luna_scanner upload --source_file update_firmware.sh --target_file /usr/local/luna-client/script/update_firmware.sh -i to_be_update_devices.txt -c 'chmod a+x /usr/local/luna-client/script/update_firmware.sh'

    luna_scanner upload --source_file update_firmware.sh --target_file /tmp/no_use.sh -i to_be_update_devices.txt -c '/usr/local/luna-client/script/update_firmware.sh http://192.168.3.100 900k'
    luna_scanner upload --source_file /Users/qichunren/Downloads/update_firmware.sh --target_file /usr/local/luna-client/script/update_firmware.sh -c 'chmod a+x /usr/local/luna-client/script/update_firmware.sh && /usr/local/luna-client/script/update_firmware.sh http://10.0.4.48 900k' -i 10_ip.txt

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
