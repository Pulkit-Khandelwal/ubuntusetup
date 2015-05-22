#!/bin/bash

#
# UPDATE / UPGRADE
#

echo "--------------- Update + Upgrade";

sudo apt-get update;
sudo apt-get -y upgrade;

#
#  INSTALL
#
echo "--------------- Installing Tools";

apt_get_packages=( "git" "curl" "nodejs-legacy" "npm" "php5-mysql" "php5-fpm" "php5-cli" "php5-mcrypt" "mcrypt" "php5-curl" "php5-json" "python-pip" "nginx" );

for i in "${!apt_get_packages[@]}"; do
	if [ $(dpkg-query -W -f='${Status}' "${apt_get_packages[$i]}" 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		echo "--------------- Installing ${apt_get_packages[$i]}";
		sudo apt-get install -y ${apt_get_packages[$i]};
	else
		echo "--------------- '${apt_get_packages[$i]}' already installed";
	fi
done

sudo php5enmod mcrypt;
sudo service nginx restart;

npm_packages=( "gulp" "bower" "browserify" );

for i in "${!npm_packages[@]}"; do

	if [ $(npm list -g "${npm_packages[$i]}" 2>/dev/null | grep -c "${npm_packages[$i]}") -eq 0 ];
	then
		echo "--------------- Installing ${npm_packages[$i]}";
		sudo npm install -g ${npm_packages[$i]};
	else
		echo "--------------- '${npm_packages[$i]}' already installed";
	fi
done

sudo chown -R $LOGNAME:$LOGNAME ~/.npm;

# composer
if [ ! -f /usr/local/bin/composer ]; then
	echo "--------------- Installing Composer";
	curl -sS https://getcomposer.org/installer | php;
	sudo mv composer.phar /usr/local/bin/composer;
else
	echo "--------------- Updating Composer";
	sudo composer self-update;
fi

# codeception
if [ ! -f /usr/local/bin/codecept ]; then
	echo "--------------- Installing Codeception";
	wget http://codeception.com/codecept.phar;
	sudo mv codecept.phar /usr/local/bin/codecept;
	sudo chmod +x /usr/local/bin/codecept;
else
	echo "--------------- Updating Codeception";
	sudo codecept self-update;
fi


#
# ADD ALIASES TO BASH
#
if [ $(cat ~/.bashrc | grep -c "mybash") -eq 0 ];
then

echo '

alias reload="sudo service nginx reload"
alias restart="sudo service nginx restart"
alias restartphp="sudo service php5-fpm restart"
alias restartsql="sudo service mysql restart"

alias hosts="sudo vi /etc/hosts"
alias phpini="sudo vi /etc/php5/fpm/php.ini"
alias mybash="vi ~/.bashrc"

alias vhosts="cd /etc/nginx/sites-available; ls -li"
alias www="cd /var/www; ls -li"
alias html="cd /var/www/production/api; ls -li"
alias dev="cd /var/www/development/api; ls -li"
alias logs="cd /var/log/nginx; ls -li"

alias dir="ls -la"
alias b="cd .."
alias ..="cd .."
alias ...="cd ../.."

alias dump="composer dump-autoload;"
alias run="codecept run functional -d;";

alias error.log="tail -f /var/log/nginx/error.log"

' >> ~/.bashrc;
	exec bash;
fi