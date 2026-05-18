# Post-Incident Review (PIR)
## Incident: API Availability Degradation
**Date:** May 16, 2026
**Severity:** Critical
**Duration:** 47 minutes
**Author:** OpenProfile DevOps Team
**Status:** Resolved

---

## Incident Summary
The OpenProfile production backend API became unavailable for 47 minutes due to a failed deployment that introduced a misconfigured environment variable, causing the Node.js process to crash on startup. The monitoring stack detected the outage within 2 minutes and fired alerts to #DevOps-Alerts on Slack.

---

## Timeline

| Time (UTC) | Event |
|---|---|
| 23:10 | Deployment triggered via GitHub Actions on `production` branch |
| 23:12 | PM2 process crashed — missing `DATABASE_URL` env variable |
| 23:12 | Blackbox Exporter detected probe failure |
| 23:14 | `ServerDown` alert fired in #DevOps-Alerts on Slack |
| 23:14 | `SloBurnRateFast` alert fired — budget burning at 14.4x |
| 23:15 | On-call engineer acknowledged alert |
| 23:18 | Engineer SSH'd into server and identified crashed PM2 process |
| 23:22 | Root cause identified — missing env variable in production |
| 23:25 | Fix applied — env variable added and app restarted |
| 23:27 | Blackbox probe success restored |
| 23:27 | `ServerDown` resolved alert fired in #DevOps-Alerts |
| 23:57 | Full incident review completed |

**Total downtime:** 47 minutes
**Detection time:** 2 minutes
**Response time:** 1 minute after alert
**Resolution time:** 11 minutes after response

---

## Root Cause
A new environment variable `DATABASE_URL` was added to the codebase but was not added to the production `.env` file on the server. The deployment succeeded in GitHub Actions because the CI environment had the variable set. The Node.js process crashed immediately on startup in production due to the missing variable.

---

## Impact
- Production API unavailable for 47 minutes
- All frontend users could not load data
- 47 minutes of error budget consumed (21.7% of monthly budget)
- Zero data loss — database was not affected

---

## What Went Wrong

### Detection
- ✅ Blackbox Exporter detected the outage in 2 minutes
- ✅ Alert fired correctly to Slack with dashboard link
- ❌ No pre-deployment checklist to verify env variables exist in production

### Response
- ✅ Engineer responded within 1 minute of alert
- ✅ Runbook guided investigation correctly
- ❌ No automated rollback triggered — manual intervention required
- ❌ Engineer had to SSH in manually to check PM2 logs

### Tooling
- ✅ Grafana dashboard showed exact time of failure
- ✅ Loki logs showed PM2 crash reason
- ❌ No automated env variable validation before deployment
- ❌ No smoke test after deployment to catch crash before traffic

---

## What Went Well
- Alert fired within 2 minutes of outage
- Slack notification included dashboard link — engineer knew exactly where to look
- Runbook was clear and guided resolution efficiently
- Recovery was fast once root cause was identified

---

## Action Items

| Action | Owner | Due Date | Priority |
|---|---|---|---|
| Add env variable validation step to GitHub Actions | Person 1 | 2026-05-23 | High |
| Add post-deployment smoke test to CI pipeline | Person 2 | 2026-05-23 | High |
| Document all required env variables in README | Person 1 | 2026-05-20 | Medium |
| Implement automated rollback on deployment failure | Person 3 | 2026-05-30 | Medium |
| Add PM2 log streaming to Loki via OTel Collector | Person 1 | 2026-05-27 | Low |

---

## Toil Identified
1. **Manual env variable management** — engineer had to manually SSH in and add env variable. Should be automated via secrets manager (AWS Secrets Manager or GitHub Secrets).
2. **Manual rollback** — engineer had to manually revert and restart. Should be automated in CI/CD pipeline with automatic rollback on health check failure.

---

## Error Budget Impact
- Monthly budget: 216 minutes (0.5% of 30 days)
- Consumed this incident: 47 minutes (21.7% of monthly budget)
- Remaining budget: 169 minutes (78.3% of monthly budget)
- Budget policy status: 🟡 Yellow — slow down and investigate

---

## Lessons Learned
1. Pre-deployment env variable validation is non-negotiable
2. Post-deployment smoke tests catch crashes before users do
3. The monitoring stack worked exactly as designed — detection was fast
4. Runbooks reduced MTTR significantly — engineer knew exactly what to check