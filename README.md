# LunaScanner

LunaScanner是一个局域网中设备扫描的命令行工具。它可以批量局域网中设备，批量执行远程命令。

## 使用场景

 我们在做的一套系统中包括服务器和许多客户端机器，它们都是Linux机器。这些客户端机器的系统（固件）都是统一刷机部署的。日常管理客户端机器是通
 过SSH加上一个private key登录进入终端，执行相应的SHELL命令来完成操作的。在平时开发和测试的过程中，经常需要统一地批量修改当前网络中客户端
 系统中的某一个文件或者重启等各种操作，于是我就创建了这个工具。

## 安装

```
$ gem install luna_scanner
```

## 使用方法

`luna_scanner`
直接输入这个命令是扫描当前网段中的客户端Linux机器，如当前机器的IP是192.168.1.23，那么扫描的网段是192.168.1.1到192.168.1.255

参数:

--ip_range 是用于设置扫描的网段，如--ip_range=192.168.0.1,192.168.4.255
   
-t  是用于设置扫描的并发线程数，如-t 180，这个数值默认是120，建议不要设置得过高
   
-r  是用于设置扫描结果的文件，默认是/tmp/lunascan.txt

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


### Work Step

1. Scan
    luna_scanner --ip_range 192.168.0.1,192.168.3.254 -t 150
    luna_scanner --ip_range 8.128.2.0,8.128.3.254 -t 150 -r /tmp/lunascan8.txt
    luna_scanner --ip_range 10.0.0.0,10.0.15.254 -t 150 -r /tmp/lunascan8.txt

    luna_scanner --ip_range 8.128.0.0,8.128.1.254 -t 150 -r /tmp/lunascan0.txt


    cat /tmp/lunascan8.txt  | grep U > /tmp/lunascan.txt

2. Update
    luna_scanner update  # /tmp/lunascan.txt

    luna_scanner change_ip --reboot



