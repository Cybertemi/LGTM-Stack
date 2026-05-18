# Runbook: ServerDown

## What is this alert?
Blackbox Exporter cannot reach one or more of your application endpoints for 2+ consecutive minutes.

## Likely Causes
- Application crashed
- PM2 process stopped
- Network issue
- Port blocked by firewall
- Server out of memory/disk

## Investigation Steps

### Step 1 — Check if server is reachable
```bash
ping 13.63.157.203
curl -v http://13.63.157.203:3001/health
```

### Step 2 — SSH in and check processes
```bash
ssh ubuntu@13.63.157.203
pm2 list
pm2 logs --lines 50
```

### Step 3 — Check system resources
```bash
free -h
df -h
sudo systemctl status
```

## How to Resolve
```bash
# Restart crashed app
pm2 restart openprofile-main-be
pm2 restart openprofile-staging-be

# If PM2 itself is down
pm2 resurrect
```

## Should I Roll Back?
Yes if crash happened immediately after deployment:
```bash
git revert HEAD
pm2 restart all
```

## Escalation
- Server unreachable via SSH → contact AWS support
- All processes down → escalate to team lead immediately