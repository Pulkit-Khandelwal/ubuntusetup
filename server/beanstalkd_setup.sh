#!/bin/bash

#
# UPDATE / UPGRADE
#

echo "--------------- Update + Upgrade";

sudo apt-get update;
sudo apt-get -y upgrade;
sudo apt-get -y dist-upgrade;

#
#  INSTALL
#
echo "--------------- Installing Tools";

apt_get_packages=( "git" "beanstalkd" "supervisor" "curl" "php5-fpm" "php5-cli" "nginx" );

for i in "${!apt_get_packages[@]}"; do
	if [ $(dpkg-query -W -f='${Status}' "${apt_get_packages[$i]}" 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		echo "--------------- Installing ${apt_get_packages[$i]}";
		sudo apt-get install -y ${apt_get_packages[$i]};
	else
		echo "--------------- '${apt_get_packages[$i]}' already installed";
	fi
done

# composer
if [ ! -f /usr/local/bin/composer ]; then
	echo "--------------- Installing Composer";
	curl -sS https://getcomposer.org/installer | php;
	sudo mv composer.phar /usr/local/bin/composer;
else
	echo "--------------- Updating Composer";
	sudo composer self-update;
fi