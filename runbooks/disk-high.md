# Runbook: DiskHighWarning / DiskHighCritical

## What is this alert?
Disk usage has exceeded threshold:
- **Warning**: Disk > 75%
- **Critical**: Disk > 90%

## Likely Causes
- Log files growing unbounded
- Prometheus metrics data accumulating
- Application generating large files
- Old deployments not cleaned up

## Investigation Steps

### Step 1 — Find what's using disk
```bash
ssh ubuntu@13.63.157.203
df -h
du -sh /* 2>/dev/null | sort -rh | head -20
```

### Step 2 — Check log sizes
```bash
du -sh /var/log/*
du -sh ~/.pm2/logs/*
```

### Step 3 — Check Prometheus data
```bash
du -sh /var/lib/prometheus/
```

## How to Resolve
```bash
# Clean old logs
sudo journalctl --vacuum-size=500M
pm2 flush

# Clean apt cache
sudo apt clean

# Clean old Prometheus data (if retention not working)
sudo systemctl restart prometheus
```

## Should I Roll Back?
Not applicable — this is infrastructure issue not code.

## Escalation
- Disk > 90% → immediate action required
- Disk full → all services will crash