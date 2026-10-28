# Security notes

A short review of the finished setup.

## What is in place

| Area | State |
|---|---|
| Network exposure of the app server | Only 80 and 443 open to everyone; SSH limited to my IP and the Instance Connect range |
| Database exposure | Not publicly accessible; allows connections only from the app server's security group |
| Separation of tiers | Application and database on different machines |
| Installer | `install` folder deleted after setup |
| Admin panel | Folder auto-renamed to a random name |
| Database tables | Random table prefix |
| Credentials | Admin and database passwords are different, strong, and not stored in this repo |
| Cost controls | Free-tier sizes, autoscaling off, zero-spend budget alert |

## Known weaknesses

- **No HTTPS.** Traffic, including admin logins, travels unencrypted over HTTP. This is acceptable for a short-lived lab, not for a real shop.
- **SSH rule for the Instance Connect range** is wider than my IP alone. It covers four AWS-owned addresses and should be removed when finished.
- **PHP and PrestaShop versions** need regular updates; there is no automatic patching of the application.
- **No WAF, rate limiting or fail2ban** in front of the shop or SSH.
- **Public address is not stable** across instance stop/start.
- Sample data from the installer is still present.

## How I would improve it

1. Add a domain and a Let's Encrypt certificate, and force HTTPS.
2. Remove the Instance Connect SSH rule and use AWS Systems Manager Session Manager instead, so SSH can stay closed entirely.
3. Add fail2ban, automatic security updates, and a WAF.
4. Run Nmap, Nikto and OWASP ZAP against my own deployment and record the findings.
5. Enable and test database backups.
