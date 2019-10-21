#!/bin/sh

# Enable and start services
sysrc -f /etc/rc.conf lighttpd_enable="YES"
service lighttpd start 2>/dev/null
sysrc -f /etc/rc.conf mysql_enable="YES"
service mysql-server start 2>/dev/null
sysrc -f /etc/rc.conf php_fpm_enable="YES"
service php-fpm start 2>/dev/null

# Set variables for username and database name
USER="dbadmin"
DB="osTicket"

# Save the config values and generate a random password 
echo "$DB" > /root/dbname
echo "$USER" > /root/dbuser
export LC_ALL=C
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 > /root/dbpassword
PASS=`cat /root/dbpassword`

# Configure mysql
mysql --protocol=socket -u root <<-EOF
CREATE DATABASE ${DB};
ALTER USER 'root'@'localhost' IDENTIFIED BY '${PASS}';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
CREATE USER '${USER}'@'localhost' IDENTIFIED BY '${PASS}';
GRANT ALL PRIVILEGES ON *.* TO '${USER}'@'localhost' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ${DB}.* TO '${USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

# Fetch osTicket, unzip into a staging directory, move files into the webserver directory
fetch https://github.com/osTicket/osTicket/releases/download/v1.12.3/osTicket-v1.12.3.zip
mkdir staging
unzip -d staging osTicket-v1.12.3.zip 
mkdir -p /usr/local/www/data
mv staging/upload/* /usr/local/www/data/
mv staging/scripts /usr/local/www/data/
rm -rf staging
# Prep for setup
cp /usr/local/www/data/include/ost-sampleconfig.php /usr/local/www/data/include/ost-config.php
chmod 0666 /usr/local/www/data/include/ost-config.php

# Send database name, login, and password to PLUGIN_INFO
echo "Database Name: $DB" > /root/PLUGIN_INFO
echo "Database User: $USER" >> /root/PLUGIN_INFO
echo "Database Password: $PASS" >> /root/PLUGIN_INFO
# Output database name, login, and password to terminal
echo "Database Name: $DB" 
echo "Database User: $USER" 
echo "Database Password: $PASS" 
echo "To view this information again, check /root/PLUGIN_INFO"



