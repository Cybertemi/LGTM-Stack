# Runbook: SslCertificateExpiringSoon

## What is this alert?
SSL certificate for one of your domains expires in less than 14 days.

## Likely Causes
- Auto-renewal failed (certbot)
- Certificate was manually installed and not set to auto-renew

## Investigation Steps

### Step 1 — Check certificate expiry
```bash
echo | openssl s_client -connect openprofile.hng.tech:443 2>/dev/null | openssl x509 -noout -dates
```

### Step 2 — Check certbot status
```bash
ssh ubuntu@13.63.157.203
sudo certbot certificates
sudo systemctl status certbot.timer
```

## How to Resolve
```bash
# Force renewal
sudo certbot renew --force-renewal

# Restart nginx/caddy after renewal
sudo systemctl restart nginx
```

## Should I Roll Back?
Not applicable.

## Escalation
- Certificate already expired → emergency renewal required immediately
- Renewal failing → check DNS records and domain ownership