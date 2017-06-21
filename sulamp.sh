#!/bin/bash

# COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

# update
echo -e "$Cyan \n Updating System.. $Color_Off"
apt-get -qq update -y
echo -e "$Green \n System updated.$Color_Off"

##############################
##      install Apache      ##
##############################
echo -e "$Cyan \n Installing Apache.. $Color_Off"
apt-get -qq install apache2 -y

# get the public IP and append it to apache2.conf
myip=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo "ServerName $myip" >> /etc/apache2/apache2.conf

# check for syntax errors
apache2ctl configtest

# restart apache
systemctl restart apache2

# allow incoming trafic on firewall for the profile Apache Full
# TODO: make a list of available profiles and allow the user to select the desired one
ufw allow in "Apache Full"

echo -e "$Green \n Apache installed.$Color_Off"

##############################
##      install MySQL       ##
##############################
echo -e "$Cyan \n Installing MySQL.. $Color_Off"
apt-get -qq install mysql-server -y

mysql_secure_installation <<EOF
secret
secret
y
y
y
y
EOF

echo -e "$Green \n MySQL installed. $Color_Off"
echo -e "$Yellow \n Please change the root password manualy. $Color_Off"

##############################################
##      install PHP and helper packages     ##
##############################################
echo -e "$Cyan \n Installing PHP.. $Color_Off"
apt-get -qq install php libapache2-mod-php php-mcrypt php-mysql -y

# make Apache look for index.php first by changing the dir.conf file
sed -i 's/ index.php//' /etc/apache2/mods-enabled/dir.conf
sed -i 's/index.html/index.php index.html/' /etc/apache2/mods-enabled/dir.conf

# restart Apache
systemctl restart apache2

# make the info.php for test
echo "<?php phpinfo(); ?>" >> /var/www/html/info.php

echo -e "$Green \n PHP installed. $Color_Off"
echo -e "$Yellow Please run info.php to check if everything is installed. $Color_Off"
echo -e "$Purple \n DONE. $Color_Off"