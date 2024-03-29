echo "Hello from provision.sh";

# Get repos fully up to date and upgraded
apt-get update;
apt-get upgrade -y;

# Require some required packages
sudo apt-get install -y software-properties-common ca-certificates lsb-release apt-transport-https;

# Install PHP repo
LC_ALL=C.UTF-8 sudo add-apt-repository ppa:ondrej/php -y;
sudo apt-get update;

# Install required packages
apt-get install -y unzip mysql-server memcached nginx;

# Install default PHP version packages
apt-get install -y php php-gd php-intl php-fpm php-cli php-dom php-zip php-imagick php-xdebug php-mysql php-mbstring php-memcached php-zip php-curl php-bcmath;

# Install PHP 7.4 packages
apt-get install -y php7.4 php7.4-gd php7.4-intl php7.4-fpm php7.4-cli php7.4-dom php7.4-zip php7.4-imagick php7.4-xdebug php7.4-mysql php7.4-mbstring php7.4-memcached php7.4-zip php7.4-curl php7.4-bcmath;

apt-get install -y php8.2 php8.2-gd php8.2-intl php8.2-fpm php8.2-cli php8.2-dom php8.2-zip php8.2-imagick php8.2-xdebug php8.2-mysql php8.2-mbstring php8.2-memcached php8.2-zip php8.2-curl php8.2-bcmath;

# If multiple PHP versions are installed, set PHP 8.2 as the default
update-alternatives --set php /usr/bin/php8.2

############ MAILCATCHER ############
# Install additional packages
apt-get install -y ruby-dev build-essential;
gem install mailcatcher;
# Update php.ini files for CLI and Apache to set sendmail_path
echo "sendmail_path = /usr/bin/env catchmail -f some@from.address" | sudo tee -a /etc/php/7.4/cli/php.ini;
echo "sendmail_path = /usr/bin/env catchmail -f some@from.address" | sudo tee -a /etc/php/7.4/apache2/php.ini;
echo "sendmail_path = /usr/bin/env catchmail -f some@from.address" | sudo tee -a /etc/php/8.2/cli/php.ini;
echo "sendmail_path = /usr/bin/env catchmail -f some@from.address" | sudo tee -a /etc/php/8.2/apache2/php.ini;
############ MAILCATCHER ############

## Set timezone to UTC
timedatectl set-timezone UTC

## Install composer
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

echo "CREATE USER 'vagrant'@'localhost' IDENTIFIED BY 'password';" | mysql;
echo "GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'localhost';" | mysql;
echo "FLUSH PRIVILEGES;" | mysql;

## Enable Xdebug for CLI and Apache
echo '
[xdebug]
xdebug.remote_host=192.168.35.10
xdebug.remote_enable=1
xdebug.client_host=10.0.2.2
xdebug.client_port=9000
xdebug.mode=debug
' >> /etc/php/8.2/fpm/php.ini;

echo '
[xdebug]
xdebug.remote_host=192.168.35.10
xdebug.remote_enable=1
xdebug.client_host=10.0.2.2
xdebug.client_port=9000
xdebug.mode=debug
' >> /etc/php/8.2/cli/php.ini;

echo '
[xdebug]
xdebug.remote_host=192.168.35.10
xdebug.remote_enable=1
xdebug.client_host=10.0.2.2
xdebug.client_port=9000
xdebug.mode=debug
' >> /etc/php/7.4/fpm/php.ini;

echo '
[xdebug]
xdebug.remote_host=192.168.35.10
xdebug.remote_enable=1
xdebug.client_host=10.0.2.2
xdebug.client_port=9000
xdebug.mode=debug
' >> /etc/php/7.4/cli/php.ini;

# Copy the NGINX configuration file and enable it
cp /vagrant/api_garagecms_nginx.conf /etc/nginx/sites-available/api.garagecms.com
ln -s /etc/nginx/sites-available/api.garagecms.com /etc/nginx/sites-enabled/

# Check NGINX configuration and restart NGINX
nginx -t && sudo systemctl restart nginx
# Check NGINX configuration and restart NGINX
nginx -t && systemctl restart nginx

## Restart services
service mysql restart;
service memcached restart;
service nginx restart;
