# Implementation steps

Region used throughout: **Europe (Stockholm), eu-north-1**. AWS has no Nigeria region, Stockholm was the account default, and it supports the free-tier instance types used here.

> Replace names, passwords and addresses with your own. Never commit passwords, key files or account IDs.

## 1. Account and budget alert

1. Create an AWS account on the **Free Plan**.
2. Open **Budgets**, choose **Create budget**, then **Use a template (simplified)**, then **Zero spend budget**, and enter an email address.

Why first: the alert warns me by email if any charge appears.

## 2. Application server (EC2)

1. Open **EC2**, then **Launch instance**.
2. Name: `shop-server`. Image: **Ubuntu Server 24.04 LTS**. Type: **t3.micro** (free tier eligible).
3. Key pair: create an RSA `.pem` key pair and keep the file private.
4. Network settings, create a new security group with:
   - SSH (22): source **My IP**
   - HTTP (80): anywhere
   - HTTPS (443): anywhere
5. Storage: **15 GiB** gp3.
6. Launch and wait for the instance to show **Running** and **3/3 checks passed**.

The launch wizard's default rule allowed all traffic from anywhere. I replaced it with the three rules above.

## 3. Separate database (RDS)

1. Open **RDS**, then **Create database**, then **Full configuration**. (Easy/express create produced the wrong engine.)
2. Engine: **MySQL**. Template: **Free tier**.
3. Identifier: `shop-db`. Credentials: self managed, with a strong master password (kept private).
4. Instance class: a **micro** class (`db.t4g.micro`). Storage: **20 GiB**, storage autoscaling **off**.
5. Connectivity: **Connect to an EC2 compute resource** and choose the app server. This makes AWS create security groups that allow only that server to reach the database.
6. Public access: **No**.
7. Additional configuration: initial database name `prestashop`.
8. Create the database, wait for **Available**, then copy the **endpoint** from the Connectivity & security tab.

## 4. Allow the browser terminal

EC2 Instance Connect connects from AWS's own address range, not from my computer. In the app server's security group, add an inbound SSH rule for the Instance Connect range for the region (`13.48.4.200/30` for eu-north-1; check AWS's published ranges for `EC2_INSTANCE_CONNECT`). Remove this rule at clean-up.

## 5. Connect and prepare the server

1. EC2, select the instance, **Connect**, **EC2 Instance Connect**, user `ubuntu`.
2. Update and install the stack:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y apache2 php libapache2-mod-php php-mysql php-gd php-curl \
  php-intl php-mbstring php-xml php-zip php-bcmath unzip mysql-client
sudo a2enmod rewrite && sudo systemctl restart apache2
```

3. Verify:

```bash
php -v                      # PHP 8.3.x
systemctl is-active apache2 # active
```

## 6. Download and place PrestaShop

Get the download link for PrestaShop Classic from the official site (prestashop.com), then on the server:

```bash
cd /tmp
wget -O ps.zip "<official download link>"
unzip -q ps.zip -d ps
sudo rm /var/www/html/index.html
sudo unzip -q /tmp/ps/prestashop.zip -d /var/www/html/
sudo chown -R www-data:www-data /var/www/html
```

## 7. Run the web installer

1. Browse to `http://<server-public-dns>/`.
2. Language, licence, and the system compatibility check (all passed).
3. Store information: country, timezone `Africa/Lagos`, an admin email and password. Leave **Enable SSL** off (the default AWS address has no certificate).
4. System configuration (the important step):
   - Database server address: the **RDS endpoint** (not `127.0.0.1`)
   - Database name: `prestashop`
   - Login: the RDS master username, with its password
   - Keep the random table prefix
5. Click **Test your database connection now!** and wait for **Database is connected**, then continue.

## 8. Finish and secure

```bash
sudo rm -rf /var/www/html/install
ls /var/www/html    # the admin folder has been renamed to a random name
```

Open the shop's address in a browser to confirm the storefront loads.

## 9. Clean-up

Terminate the EC2 instance, delete the RDS instance (and automated backups), and remove the extra SSH rule.
