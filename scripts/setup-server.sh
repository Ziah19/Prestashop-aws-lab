#!/usr/bin/env bash
# Commands from the lab, collected for reference.
# Meant for a fresh Ubuntu 24.04 LTS server. Read it first and run it
# on a throwaway machine; this is a lab record, not a hardened installer.
#
# Usage: ./setup-server.sh "<official PrestaShop download link>"
set -euo pipefail

PRESTASHOP_URL="${1:?Pass the official PrestaShop download link as the first argument}"

sudo apt update && sudo apt upgrade -y
sudo apt install -y apache2 php libapache2-mod-php php-mysql php-gd php-curl \
  php-intl php-mbstring php-xml php-zip php-bcmath unzip mysql-client
sudo a2enmod rewrite
sudo systemctl restart apache2

cd /tmp
wget -O ps.zip "$PRESTASHOP_URL"
unzip -q ps.zip -d ps
sudo rm -f /var/www/html/index.html
sudo unzip -q ps/prestashop.zip -d /var/www/html/
sudo chown -R www-data:www-data /var/www/html

php -v
systemctl is-active apache2

echo
echo "Next: open http://<server-public-dns>/ and run the web installer."
echo "Use the RDS endpoint as the database server (not 127.0.0.1)."
echo "When the installer finishes, delete the install folder:"
echo "  sudo rm -rf /var/www/html/install"
