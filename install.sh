#!/bin/bash
home=/home/pi
config=/home/pi/printer_data/config
system=/home/pi/printer_data/config/src/system_config
cd $home
git clone --branch develop https://github.com/re3Dprinting/klipper_config
rm $config/printer.cfg
rm $config/moonraker.conf
cp -a $home/klipper_config/. $config/
pip3 install gitpython
apt install xinput ripgrep nmap xscreensaver* -y
cp $system/screensaver/.xscreensaver $home/.xscreensaver
cp $system/klipper/klipper_config.service /etc/systemd/system/.
mv $system/fullpageos.txt /boot/fullpageos.txt
mv $system/lightdm.conf /etc/lightdm/lightdm.conf
mv $system/01_debian.conf /usr/share/lightdm/lightdm.conf.d/01_debian.conf
mv $system/start_chromium_browser $home/scripts/start_chromium_browser
cp $system/display/lightdm_watchman.service /etc/systemd/system/lightdm_watchman.service
chmod 644 /etc/systemd/system/lightdm_watchman.service
systemctl enable lightdm_watchman.service
chmod 644 /etc/systemd/system/klipper_config.service
systemctl enable klipper_config.service
sh $system/usb/setup-usbmount.sh
sed -i "s/console=serial0,115200//g" /boot/cmdline.txt
mv $home/stack-install/klipper.env $home/printer_data/systemd/klipper.env
chmod +x $config/get_serial.sh
python3 $config/src/reload.py

