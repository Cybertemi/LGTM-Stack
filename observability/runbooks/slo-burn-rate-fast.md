# Runbook: SloBurnRateFast

## What is this alert?
The error budget is burning at 14.4x the normal rate. At this pace, 2% of the monthly error budget will be gone within 1 hour.

## What does this mean?
Your SLO is 99.5% availability. Your monthly error budget is ~216 minutes of downtime. A 14.4x burn rate means you are consuming that budget 14x faster than allowed.

## Likely Causes
- Service is partially or fully down
- High error rate on critical endpoints
- Latency so high requests are timing out

## Investigation Steps

### Step 1 — Check what is failing
Open Grafana → Unified Observability dashboard → Error Rate panel

### Step 2 — Check logs for errors
Open Grafana → Unified Observability → Logs panel → look for 5xx errors

### Step 3 — Find the trace
Click a trace_id in the logs panel → opens Tempo → find the failing service

## How to Resolve
- Fix the root cause immediately
- If deployment caused it: roll back now
- If infrastructure: escalate to on-call

## Should I Roll Back?
Yes — at fast burn rate, roll back first, investigate later:
```bash
cd /var/www/openprofile-be/main
git revert HEAD
pm2 restart openprofile-main-be
```

## Escalation
Fast burn = immediate escalation. Wake up on-call engineer now.