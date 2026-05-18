# Runbook: NoRecentDeployments

## What is this alert?
No successful deployments have been recorded in the last 7 days.

## Likely Causes
- CI/CD pipeline is broken
- No code has been merged to main/staging
- Pushgateway is not receiving metrics from GitHub Actions
- GitHub Actions workflow is disabled

## Investigation Steps

### Step 1 — Check GitHub Actions
Go to GitHub → Actions → check if workflows are running

### Step 2 — Check Pushgateway
```bash
curl -s http://98.84.164.17:9091/metrics | grep deployment_total
```

### Step 3 — Check workflow file
Verify `.github/workflows/dora-metrics.yml` exists and is correct

## How to Resolve
- Fix broken pipeline
- Re-enable disabled workflows
- Check Pushgateway connectivity from GitHub Actions

## Escalation
If pipeline broken > 2 days → notify team lead