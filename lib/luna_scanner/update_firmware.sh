#!/bin/bash

NOW=`date '+%Y-%m-%d %H:%M'`

echo "Start at ${NOW}"

UPDATE_HOST=http://10.0.4.48
LIMIT_SPEED=900k

if [ $# -ge 1 ]; then
  echo "Use update host $1"
  UPDATE_HOST=$1
else
  echo "Use default update host ${UPDATE_HOST}"
fi

if [ $# -ge 2 ]; then
  LIMIT_SPEED=$2
  echo "Use download speed ${LIMIT_SPEED}"
else
  echo "Use default download speed ${LIMIT_SPEED}"
fi

if [ ! -d /root ]; then
  echo "/root directory not exist! Exit"
  exit 1
fi

if [ ! -f /proc/itc_sn/sn ]; then
  echo "/proc/itc_sn/sn file not exist! Exit"
  exit 1
fi

if [ ! -f /boot/uboot/uEnv.txt ]; then
  echo "/boot/uboot/uEnv.txt file not exist! Exit"
  exit 1
fi

which wget
if [ ! $? -eq 0 ]; then
    echo "wget tool not installed. Exit"
    exit 1
fi

which md5sum
if [ ! $? -eq 0 ]; then
    echo "md5sum tool not installed. Exit"
    exit 1
fi

which awk
if [ ! $? -eq 0 ]; then
    echo "awk tool not installed. Exit"
    exit 1
fi

SN=`cat /proc/itc_sn/sn`
echo "Serial NO. ${SN}"


echo "Start download firmware.md5 file."
# tell server I have started.
wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=1 &> /dev/null
sleep 1
wget -O /root/firmware.md5 ${UPDATE_HOST}/static/firmwares/firmware.md5 --limit-rate=${LIMIT_SPEED}
ret=$?
if [ ! $ret -eq 0 ]; then
    echo "firmware.md5 file downlaod failed! ${ret}"
    wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=401\&reason=firmware.md5_download_failed &> /dev/null
    exit 1
fi

echo "Start download package 1 -> vardir ..."
wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=2 &> /dev/null
sleep 1
wget -O /root/vardir.tar.xz ${UPDATE_HOST}/static/firmwares/vardir.tar.xz --limit-rate=${LIMIT_SPEED}
ret=$?
if [ ! $ret -eq 0 ]; then
    echo "Package vardir.tar.xz download failed! ${ret}"
    wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=402\&reason=vardir.tar.xz_download_failed &> /dev/null
    exit 1
fi

echo "Start download package 2 -> rootfs.tar.xz  ..."
wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=3 &> /dev/null
sleep 1
wget -O /root/rootfs.tar.xz ${UPDATE_HOST}/static/firmwares/rootfs.tar.xz --limit-rate=${LIMIT_SPEED}
ret=$?
if [ ! $ret -eq 0 ]; then
    echo "Package rootfs.tar.xz download failed! ${ret}"
    wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=403\&reason=rootfs.tar.xz_download_failed &> /dev/null
    exit 1
fi

echo "Start download uImage ..."
wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=4 &> /dev/null
sleep 1
wget -O /root/uImage ${UPDATE_HOST}/static/firmwares/uImage --limit-rate=${LIMIT_SPEED}
ret=$?
if [ ! $ret -eq 0 ]; then
    echo "Package uImage download failed! ${ret}"
    wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=404\&reason=uImage_download_failed &> /dev/null
    exit 1
fi

echo "Finished download. Start validate firmware."

if [ ! -f /root/firmware.md5 ]; then
  echo "/root/firmware.md5 not exist. Exit"
  wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=401\&reason=firmware.md5_not_exist &> /dev/null
  exit 1
fi

if [ ! -f /root/vardir.tar.xz ]; then
  echo "/root/vardir.tar.xz not exist. Exit"
  wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=402\&reason=vardir.tar.xz_not_exist &> /dev/null
  exit 1
fi

if [ ! -f /root/rootfs.tar.xz ]; then
  echo "/root/rootfs.tar.xz not exist. Exit"
  wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=403\&reason=rootfs.tar.xz_not_exist &> /dev/null
  exit 1
fi

if [ ! -f /root/uImage ]; then
  echo "/root/uImage not exist. Exit"
  wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=404\&reason=uImage_not_exist &> /dev/null
  exit 1
fi

cd /root

Vardir_md5=`md5sum vardir.tar.xz | awk -F' ' '{print $1}'`
Vardir_md5_download=`grep vardir firmware.md5 | awk -F' ' '{print $1}'`

if test "${Vardir_md5}" != "${Vardir_md5_download}" ; then
    echo "vardir.tar.xz's md5 isn't matched"
    wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=422\&reason=vardir.tar.xz_md5_not_matched &> /dev/null
    exit 2
fi

Root_md5=`md5sum rootfs.tar.xz | awk -F' ' '{print $1}'`
Root_md5_download=`grep rootfs firmware.md5 | awk -F' ' '{print $1}'`

if test "${Root_md5}" != "${Root_md5_download}" ; then
    echo "rootfs.tar.xz's md5 isn't matched"
    wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=423\&reason=rootfs.tar.xz_md5_not_matched &> /dev/null
    exit 2
fi

UImage_md5=`md5sum uImage | awk -F' ' '{print $1}'`
UImage_md5_download=`grep uImage firmware.md5 | awk -F' ' '{print $1}'`

if test "${UImage_md5}" != "${UImage_md5_download}" ; then
    echo "uImage's md5 isn't matched"
    wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=424\&reason=uImage_md5_not_matched &> /dev/null
    exit 2
fi

wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=13 &> /dev/null

echo "Validation passed. Start setup ..."
sleep 1

echo "Updating kernel ..."
sleep 1
cp -rf /root/uImage /boot/uboot/uImage
ret=$?
if [ ! $ret -eq 0 ]; then
    echo "Updating uImage failed: #{ret}"
    wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=443\&reason=uImage_copy_failed &> /dev/null
    exit 1
fi
echo "kernel updated success"

cat - <<'EOF' > /boot/uboot/update_rootfs.sh
#!/bin/bash

set -xe

DIR=`pwd`
MMC_DEV=/dev/mmcblk0
ROOTFS_PART=${MMC_DEV}p2
ROOTDIR_PART=${MMC_DEV}p5
VARDIR_PART=${MMC_DEV}p6

ROOTFS_PATH=/rootfs
ROOTDIR_PATH=/rootdir
VARDIR_PATH=/vardir

#ROOTFS_URL="http://192.168.8.80/rootfs-release.tar.xz"
#ROOTDIR_URL=
#VARDIR_URL=

mount_parts(){
  ## make dir if missing
  mkdir -p ${ROOTFS_PATH}
  mkdir -p ${ROOTDIR_PATH} #not updating this at the moment.
  mkdir -p ${VARDIR_PATH}

  ## mount to correct dir
  mount ${ROOTFS_PART} ${ROOTFS_PATH}
  mount ${ROOTDIR_PART} ${ROOTDIR_PATH}
  mount ${VARDIR_PART} ${VARDIR_PATH}
}

update_parts(){
  ##get parts
  if [ -f ${ROOTDIR_PATH}/rootfs.tar.xz ]; then
    echo "Already dl'ed."
  else
    echo "No update packages, skipping."
 #   wget -O ${ROOTDIR_PATH}/rootfs.tar.xz ${ROOTFS_URL}
 #   wget -O ${ROOTDIR_PATH}/rootdir.tar.xz ${ROOTDIR_URL}
 #   wget -O ${ROOTDIR_PATH}/vardir.tar.xz ${VARDIR_URL}
  fi

  #flash parts
  cd ${ROOTFS_PATH}
  cp ${ROOTFS_PATH}/etc/network/interfaces /root/interfaces
  rm -rf *
  xzcat ${ROOTDIR_PATH}/rootfs.tar.xz | tar xv

  #cd ${ROOTDIR_PATH}
  #rm -rf *
  #xzcat ${ROOTDIR_PATH}/rootdir.tar.xz | tar xv

  cd ${VARDIR_PATH}
  cp ${VARDIR_PATH}/lib/luna/luna_client.sqlite3 /root/ || true
  rm -rf *
  xzcat ${ROOTDIR_PATH}/vardir.tar.xz | tar xv
  mv /root/luna_client.sqlite3 ${VARDIR_PATH}/lib/luna/ || true
  # make sure to copy authorized_keys
  mkdir -p ${ROOTDIR_PATH}/.ssh || true
  cp -f ${ROOTFS_PATH}/root/.ssh/authorized_keys ${ROOTDIR_PATH}/.ssh/ || true
  mv /root/interfaces ${ROOTFS_PATH}/etc/network/interfaces || true
}

cleaning(){
  rm -rf ${ROOTDIR_PATH}/rootfs.tar.xz   || true
  rm -rf ${ROOTDIR_PATH}/rootdir.tar.xz  || true
  rm -rf ${ROOTDIR_PATH}/vardir.tar.xz   || true
}

verify(){
  sed -i "s/mmcblk0p3/mmcblk0p2/g" ${BOOTFS_PATH}/uEnv.txt
}

umount_parts(){
  cd ${DIR}
  umount ${ROOTFS_PART} || true
  umount ${ROOTDIR_PART} || true
  umount ${VARDIR_PART} || true
}


#do the job
umount_parts
mount_parts
update_parts
#verify
cleaning
umount_parts
EOF

chmod 770 /boot/uboot/update_rootfs.sh

sed -i "s/mmcblk0p2/mmcblk0p3/g" /boot/uboot/uEnv.txt
echo "Finished. Restarting device."

wget -qO- ${UPDATE_HOST}/v3/update/report_progress?sn=${SN}\&status=20 &> /dev/null
reboot
