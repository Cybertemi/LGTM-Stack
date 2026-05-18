# Runbook: SloErrorBudgetExhausted

## What is this alert?
The 30-day error budget has been fully consumed. Your service has been less reliable than promised.

## Immediate Actions
1. Stop all feature deployments immediately
2. Notify team lead and stakeholders
3. Start reliability sprint

## What happens now?
Per the Error Budget Policy:
- No new features until budget recovers
- All engineering effort goes to reliability
- Daily SLO review meetings until resolved

## Investigation
Review the last 30 days in Grafana → SLO dashboard → identify the biggest incidents that consumed budget.

## Escalation
This requires team lead and stakeholder notification immediately.