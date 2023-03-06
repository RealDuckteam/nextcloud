#!/bin/bash

# Update system
apt-get update
apt-get upgrade -y

# Install required packages
apt-get install -y apache2 mariadb-server libapache2-mod-php7.4 \
php7.4-gd php7.4-mysql php7.4-curl php7.4-mbstring \
php7.4-intl php7.4-gmp php7.4-bcmath php-imagick \
php7.4-xml php7.4-zip php7.4-bz2 php7.4-apcu php7.4-redis \
wget unzip sudo

# Download Nextcloud and move to web directory
wget https://download.nextcloud.com/server/releases/nextcloud-22.2.0.zip
unzip nextcloud-22.2.0.zip -d /var/www/
mv /var/www/nextcloud /var/www/html/

# Set ownership and permissions
chown -R www-data:www-data /var/www/html/nextcloud
chmod -R 755 /var/www/html/nextcloud

# Create database and user
mysql -e "CREATE DATABASE nextcloud;"
mysql -e "CREATE USER 'benutzername'@'localhost' IDENTIFIED BY 'passwort"
mysql -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'benutzername'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Enable required Apache modules
a2enmod rewrite headers env dir mime

# Configure Apache virtual host
cat << EOF > /etc/apache2/sites-available/nextcloud.conf
<VirtualHost *:80>
ServerAdmin admin@example.com
DocumentRoot /var/www/html/nextcloud/
ServerName example.com
ServerAlias example.com

<Directory /var/www/html/nextcloud/>
Options +FollowSymlinks
AllowOverride All
Require all granted
<IfModule mod_dav.c>
Dav off
</IfModule>
SetEnv HOME /var/www/html/nextcloud
SetEnv HTTP_HOME /var/www/html/nextcloud
</Directory>

ErrorLog \${APACHE_LOG_DIR}/error.log
CustomLog \${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOF

# Enable virtual host and restart Apache
a2ensite nextcloud.conf
systemctl restart apache2

# Cleanup
rm nextcloud-22.2.0.zip

echo "Nextcloud installation completed. Please go to example.com to finish the setup."
