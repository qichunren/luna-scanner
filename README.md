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

###　批量更新终端设备

1. 批量扫描当前网段的设置
2. 修改扫描结果的文件，只留下需要更新的设备的文本行
3. 远程更新命令批量执行


    luna_scanner --ip_range=10.0.0.1,10.0.15.150 -t 150 -r 10_ip.txt

<pre>
------IP-----------SN---------MODEL-----VERSION------
      10.0.6.27 00000389    T-7203D  20131112.0506
     10.0.6.221 00000208    T-7203D  20131112.0506
    10.0.10.227 00000032    T-7203D  20131209.2239
     10.0.11.40 00000307    T-7203D  20131112.0506
    10.0.13.220 00000262    T-7203D  20131112.0506

5 devices found.
Write scan result to /Users/qichunren/RubymineProjects/luna_scanner/10_ip.txt
</pre>

    vim 10_ip.txt # Remote device which ip is '10.0.10.227', it is latest version, so I remove this text line.
    # Because new version update_firmware.sh file is not compatible with old clone, so before we update firmware, we should upload the new one to replace old one.
    # Then invoke update command to upgrade firmware from remote luna-server.
    luna_scanner upload --source_file /Users/qichunren/Downloads/update_firmware.sh --target_file /usr/local/luna-client/script/update_firmware.sh -c 'chmod a+x /usr/local/luna-client/script/update_firmware.sh && /usr/local/luna-client/script/update_firmware.sh http://10.0.4.48 1300k' -i 10_ip.txt

    ## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


scp ~/Downloads/update_firmware.sh root@10.0.6.12:/usr/local/luna-client/script/update_firmware.sh
scp ~/Downloads/update_firmware.sh root@10.0.7.156:/usr/local/luna-client/script/update_firmware.sh

ssh root@10.0.6.12 'chmod a+x /usr/local/luna-client/script/update_firmware.sh && /usr/local/luna-client/script/update_firmware.sh http://10.0.4.48 1300k'
ssh root@10.0.7.156 'chmod a+x /usr/local/luna-client/script/update_firmware.sh && /usr/local/luna-client/script/update_firmware.sh http://10.0.4.48 1300k'