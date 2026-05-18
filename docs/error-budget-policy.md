Error Budget Policy
Overview
This document defines how the team responds when error budgets are being consumed. It answers four questions: what happens at 50% consumed, what happens at 100% consumed, who owns the decision, and how often SLOs are reviewed.

What is an Error Budget?
An error budget is the amount of unreliability we are allowed to have while still meeting our SLO targets. It is calculated as:

Error Budget = (1 - SLO target) x measurement window

Our error budgets for the current 30-day window:

SLO	Target	Error Budget
Availability	99.5%	216 minutes downtime
Latency	95% under 500ms	5% of requests may be slow
Error Rate	99% success	1% of requests may fail
Why Error Budgets Matter
Without an error budget there are two failure modes:

Too strict: every incident triggers a blame session and deployment freeze. Engineers become afraid to ship.

Too loose: nobody cares about reliability until users complain loudly. Incidents become routine.

Error budgets solve this by making reliability a shared engineering resource. The budget belongs to the whole team. How you spend it is a team decision.

The Four Stages
Stage 1 — Green (0% to 50% consumed)
Everything is normal. The team operates at full velocity.

What this means:

Deploy as frequently as needed
Experiment and take reasonable risks
Monitor burn rate dashboards weekly
Actions:

No special actions required
Continue normal deployment practices
Review SLO compliance in weekly team standup
Stage 2 — Yellow (50% to 75% consumed)
The budget is being consumed faster than expected. The team needs to slow down and investigate.

What this means:

Half the monthly budget is already spent
Current trajectory may exhaust the budget before month end
Something is consuming reliability faster than normal
Actions:

Pause non-critical feature deployments
Investigate what is consuming the budget
Review recent deployments for reliability regressions
Increase deployment review requirements
Daily check of burn rate dashboard
Team lead notified immediately
Who decides: Team lead in consultation with the team.

Stage 3 — Orange (75% to 100% consumed)
The budget is critically low. Only essential work continues.

What this means:

Less than 25% of the monthly budget remains
Any significant incident will exhaust the budget completely
Reliability is the top priority until the window resets
Actions:

Stop all non-critical deployments immediately
Only deploy hotfixes and reliability improvements
All deployments require team lead approval
Daily incident review meeting
Begin reliability sprint planning
Escalate to senior engineer if cause is not identified
Who decides: Team lead has final authority. No deployment without explicit approval.

Stage 4 — Red (100% consumed — Budget Exhausted)
The error budget is fully consumed. The SLO has been violated this month.

What this means:

We have used more unreliability than we promised
Users have been impacted beyond acceptable levels
The team is in reliability sprint mode
Actions:

Full feature freeze — no new features ship this month
All engineering effort redirected to reliability improvements
Post-incident review mandatory for the events that consumed the budget
SLO targets reviewed — were they realistic?
Daily reliability standup until budget window resets
Root cause of budget exhaustion documented and fixed
Who decides: Team lead owns the feature freeze decision. Senior engineer reviews all reliability work before it ships.

Burn Rate Thresholds
Burn rate tells us how fast we are consuming the budget relative to normal.

A burn rate of 1x means we are consuming budget at exactly the right pace to exhaust it at the end of the 30-day window.

Burn Rate	Meaning	Action
Below 1x	Budget consumption is sustainable	No action
1x to 5x	Slightly elevated — monitor closely	Weekly review
5x (slow burn)	Will exhaust budget in 6 days	Warning alert fires
14.4x (fast burn)	Will exhaust budget in 50 hours	Critical alert fires
Alert Thresholds
Two burn rate alerts are configured:

Fast Burn Alert (Critical)

Condition: 2% of error budget consumed in 1 hour
Burn rate: 14.4x normal
Meaning: budget will be exhausted in approximately 50 hours
Action: immediate investigation required
Slack: fires to #DevOps-Alerts as CRITICAL
Slow Burn Alert (Warning)

Condition: 5% of error budget consumed in 6 hours
Burn rate: 5x normal
Meaning: budget will be exhausted in approximately 5 days
Action: investigate before next deployment
Slack: fires to #DevOps-Alerts as WARNING
SLO Review Schedule
Monthly Review (last Friday of each month):

Review SLO compliance for the past 30 days
Review error budget consumption
Decide whether to tighten or relax any SLO targets
Review and update runbooks if needed
Document decisions in the team wiki
Quarterly Review (every 3 months):

Are our SLO targets still appropriate for the service maturity?
Are there new SLIs we should be tracking?
What toil can we eliminate to improve reliability?
Are our error budget policies working?
Decision Authority
Decision	Owner
Pause non-critical deployments	Team lead
Full feature freeze	Team lead
SLO target changes	Team lead + senior engineer
Reliability sprint scope	Whole team
Post-incident review	Whole team
What Counts as Budget Consumption
The following events consume error budget:

Availability budget:

Service unreachable (Blackbox probe failures)
Planned maintenance windows
Deployment downtime
Latency budget:

Requests exceeding 500ms threshold
Database slow queries affecting response time
Network congestion events
Error rate budget:

5xx responses from the API service
Failed health check responses
Timeout responses
What Does NOT Count as Budget Consumption
Synthetic test traffic
Internal health check endpoints
Monitoring tool traffic
Explicitly excluded maintenance windows (pre-announced)
Last updated: May 2026 Owner: DevOps Team

