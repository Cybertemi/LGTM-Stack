# Runbook: HighResponseTime

## What is this alert?
HTTP response time has been above 2 seconds for 5+ minutes.

## Likely Causes
- Database queries slow
- External API dependency slow
- High CPU causing request queuing
- Memory pressure causing GC pauses

## Investigation Steps

### Step 1 — Check current response times
Open Grafana → Blackbox Exporter dashboard → Response Time panel

### Step 2 — Check application logs for slow queries
```bash
ssh ubuntu@13.63.157.203
pm2 logs openprofile-main-be --lines 100 | grep -i "slow\|timeout\|error"
```

### Step 3 — Check database connections
```bash
pm2 logs openprofile-main-be --lines 50 | grep -i "db\|database\|query"
```

## How to Resolve
- Restart app if memory pressure: `pm2 restart openprofile-main-be`
- If DB slow: check database server health
- If external API: add timeout and fallback

## Should I Roll Back?
Roll back if latency started after deployment.

## Escalation
- Response time > 10s → page on-call
- All endpoints slow → escalate to team lead