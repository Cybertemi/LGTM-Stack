# Runbook: MemoryHighWarning / MemoryHighCritical

## What is this alert?
Memory usage has exceeded threshold:
- **Warning**: Memory > 80% for 5+ minutes
- **Critical**: Memory > 90% for 5+ minutes

## Likely Causes
- Memory leak in application
- Too many PM2 processes running
- Large response payloads not being garbage collected
- Node.js heap growing unbounded

## Investigation Steps

### Step 1 — Check memory usage
```bash
ssh ubuntu@13.63.157.203
free -h
ps aux --sort=-%mem | head -10
```

### Step 2 — Check Node.js heap
```bash
pm2 show openprofile-main-be
pm2 show openprofile-staging-be
```

### Step 3 — Check for memory leak pattern
Open Grafana → Node Exporter dashboard → Memory panel
Look for steady upward climb over hours = memory leak

## How to Resolve
- Restart the app to free memory: `pm2 restart openprofile-main-be`
- If persistent: investigate heap dumps
- Clear system cache: `sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches`

## Should I Roll Back?
Roll back if memory growth started after a deployment.

## Escalation
- Memory > 90% → page on-call immediately
- Memory exhausted → server will OOM kill processes automatically