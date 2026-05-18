# Runbook: SloBurnRateSlow

## What is this alert?
The error budget is burning at 5x the normal rate. At this pace, 5% of the monthly error budget will be gone within 6 hours.

## What does this mean?
Not an emergency but needs attention before it becomes one. You have time to investigate properly.

## Likely Causes
- Intermittent errors on some endpoints
- Slow memory leak causing occasional timeouts
- Flaky external dependency

## Investigation Steps

### Step 1 — Check error budget remaining
Open Grafana → SLO & Error Budget dashboard → Budget Remaining panel

### Step 2 — Identify which endpoint is failing
Open Grafana → Unified Observability → Error Rate panel → filter by endpoint

### Step 3 — Check recent deployments
```bash
cd /var/www/openprofile-be/main
git log --oneline -10
```

## How to Resolve
- Investigate and fix the intermittent error
- Consider a feature freeze if budget < 25% remaining
- Document findings in incident log

## Should I Roll Back?
Only if a recent deployment is clearly the cause.

## Escalation
- Budget < 25% remaining → notify team lead
- Budget < 10% remaining → consider feature freeze