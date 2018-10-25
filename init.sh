#!/bin/bash
checkRoot()
{
    if [ $UID -ne 0 ]; then
        echo 'Error: Please run as root user.'
        exit 1
    fi
}
Set_Swap()
{
	echo "###################################"
	echo "## Memrory Information"
	echo "###################################"
	free -m
	echo "###################################"
	read -p "Do you want to set swap? (y or n) " action0
	if [ "$action0" == "Y" ] || [ "$action0" == "y" ]; then
		read -p "Enter swap quote (MB): " action1
		read -p "Do you want to modify swappiness?(y or n): " action2
		if [ "$action2" == "Y" ] || [ "$action2" == "y" ]; then
			echo "Now, swappiness is  `cat /proc/sys/vm/swappiness`"
			read -p "Enter new swappiness number(0-100): " action3
			echo "Swappiness: $action3"
			sed -i '/vm.swappiness/d' /etc/sysctl.conf
			echo "vm.swappiness=$action3" >> /etc/sysctl.conf
			sysctl -p >/dev/null 2>&1
		fi
		echo "Set $action1 MB swap"
		dd if=/dev/zero of=/home/swap01 bs=1M count=$action1
		mkswap /home/swap01
		swapon /home/swap01
		echo "/home/swap01 swap swap defaults 0 0" >> /etc/fstab
	fi
}
Enable_Rc_Local()
{
PART1=`systemctl status rc-local | grep -i active | awk -F ' ' '{print $2}'`
PART2=`ls /etc/rc.local`
if [ "$PART1" == "inactive" ] && [ "$PART2" != "/etc/rc.local" ]; then
cat <<EOF >/etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

exit 0
EOF
chmod +x /etc/rc.local
systemctl start rc-local
systemctl status rc-local | grep -i active
fi
echo "Success"
}


checkRoot
dpkg-reconfigure tzdata
Set_Swap
apt-get -y update && apt-get -y upgrade
apt-get -y install coreutils
apt-get -y install net-tools
apt-get -y install dnsutils
apt-get -y install xz-utils
apt-get -y install wget
apt-get -y install curl
apt-get -y install ca-certificates
apt-get -y install file
apt-get -y install grep
apt-get -y install gawk
apt-get -y install sed
apt-get -y install gzip
apt-get -y install libc-bin
apt-get -y install cpio
apt-get -y install openssl
apt-get -y install screen
apt-get -y install python2.7
apt-get -y install python
apt-get -y install locales

sed -i "s/#zh_CN/zh_CN/g" /etc/locale.gen
sed -i "s/# zh_CN/zh_CN/g" /etc/locale.gen
sed -i "s/#  zh_CN/zh_CN/g" /etc/locale.gen
sed -i "s/#   zh_CN/zh_CN/g" /etc/locale.gen
sed -i "s/#    zh_CN/zh_CN/g" /etc/locale.gen
sed -i "s/#	zh_CN/zh_CN/g" /etc/locale.gen
sed -i "s/#		zh_CN/zh_CN/g" /etc/locale.gen
sed -i "s/#			zh_CN/zh_CN/g" /etc/locale.gen
sed -i "s/#				zh_CN/zh_CN/g" /etc/locale.gen
sed -i "s/#en_US/en_US/g" /etc/locale.gen
sed -i "s/# en_US/en_US/g" /etc/locale.gen
sed -i "s/#  en_US/en_US/g" /etc/locale.gen
sed -i "s/#   en_US/en_US/g" /etc/locale.gen
sed -i "s/#    en_US/en_US/g" /etc/locale.gen
sed -i "s/#	en_US/en_US/g" /etc/locale.gen
sed -i "s/#		en_US/en_US/g" /etc/locale.gen
sed -i "s/#			en_US/en_US/g" /etc/locale.gen
sed -i "s/#				en_US/en_US/g" /etc/locale.gen
locale-gen

mkdir -p /root/custom_scripts/iptables

cat <<EOF >/root/custom_scripts/iptables/save.sh
#!/bin/bash
iptables-save > /root/custom_scripts/iptables/ipt.save
EOF
chmod +x /root/custom_scripts/iptables/save.sh

cat <<EOF >/root/custom_scripts/iptables/restore.sh
#!/bin/bash
cat /root/custom_scripts/iptables/ipt.save | iptables-restore
EOF
chmod +x /root/custom_scripts/iptables/restore.sh

Enable_Rc_Local
wget --no-check-certificate -O /root/setup_sv.sh https://raw.githubusercontent.com/binghe3337/install-supervisor-new/master/setup_sv.sh
chmod +x /root/setup_sv.sh
/root/setup_sv.sh
