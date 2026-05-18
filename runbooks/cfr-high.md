# Runbook: ChangeFailureRateHigh

## What is this alert?
More than 15% of deployments in the last 7 days have resulted in failures or rollbacks.

## Likely Causes
- Insufficient testing before deployment
- Missing environment variables in production
- Breaking API changes not caught in staging
- Dependency version conflicts

## Investigation Steps

### Step 1 — Review recent failed deployments
Go to GitHub → Actions → filter by failed workflows

### Step 2 — Check what changed
```bash
cd /var/www/openprofile-be/main
git log --oneline -20
```

### Step 3 — Review staging test coverage
Check if staging tests are catching issues before production deployment

## How to Resolve
- Add more tests to CI pipeline
- Enforce staging deployment before production
- Add smoke tests after each deployment
- Review PR review process

## Escalation
CFR > 30% → engineering process review required