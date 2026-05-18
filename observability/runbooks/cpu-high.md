# Runbook: CpuHighWarning / CpuHighCritical

## What is this alert?
CPU usage on the server has exceeded the threshold:
- **Warning**: CPU > 80% for 5+ minutes
- **Critical**: CPU > 90% for 10+ minutes

## Likely Causes
- Traffic spike hitting the backend
- Runaway process or memory leak
- Background job consuming CPU
- Insufficient server resources

## Investigation Steps

### Step 1 — Identify the process consuming CPU
```bash
ssh ubuntu@13.63.157.203
top -bn1 | head -20
ps aux --sort=-%cpu | head -10
```

### Step 2 — Check application logs
```bash
pm2 logs openprofile-main-be --lines 50
pm2 logs openprofile-staging-be --lines 50
```

### Step 3 — Check if it's a traffic spike
Open Grafana → Node Exporter dashboard → check Request Rate panel

## How to Resolve
- If runaway process: `pm2 restart openprofile-main-be`
- If traffic spike: scale up or enable rate limiting
- If background job: identify and kill with `kill -9 PID`

## Should I Roll Back?
Roll back if CPU spike started exactly when a new deployment happened:
```bash
cd /var/www/openprofile-be/main
git log --oneline -5
git revert HEAD
pm2 restart openprofile-main-be
```

## Escalation
- 50% CPU for > 30 mins → notify team lead
- 90% CPU for > 10 mins → page on-call engineer immediately