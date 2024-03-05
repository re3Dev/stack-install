#!/bin/bash

home=/home/pi
config=$home/printer_data/config
system=$config/src/system_config
klipper_config_repo=https://github.com/re3Dprinting/klipper_config
branch=experimental
packages=(raspberrypi-kernel-headers build-essential bc dkms git xinput ripgrep nmap xscreensaver*)
services=(klipper_config lightdm_watchman)

cd $home
git clone --branch $branch $klipper_config_repo

# Remove old config files
rm $config/printer.cfg $config/moonraker.conf

# Copy new config files
cp -a $home/klipper_config/. $config/

pip3 install gitpython
apt install ${packages[@]} -y

# Copy system files
cp $system/screensaver/.xscreensaver $home/.xscreensaver
cp $system/klipper/klipper_config.service /etc/systemd/system/.
cp $system/display/lightdm_watchman.service /etc/systemd/system/lightdm_watchman.service

# Move system files
mv $system/fullpageos.txt /boot/fullpageos.txt
mv $system/config.txt /boot/config.txt
mv $system/lightdm.conf /etc/lightdm/lightdm.conf
mv $system/01_debian.conf /usr/share/lightdm/lightdm.conf.d/01_debian.conf
mv $system/start_chromium_browser $home/scripts/start_chromium_browser
mv $home/stack-install/klipper.env $home/printer_data/systemd/klipper.env

# Set permissions and enable services
for service in ${services[@]}; do
  chmod 644 /etc/systemd/system/$service.service
  systemctl enable $service.service
done

sh $system/usb/setup-usbmount.sh
sed -i "s/console=serial0,115200//g" /boot/cmdline.txt
chmod +x $config/get_serial.sh
curl -sf -L https://raw.githubusercontent.com/Sineos/useful_bits/main/Linux/fix_debian_udev.sh | sudo bash
python3 $config/src/reload.py