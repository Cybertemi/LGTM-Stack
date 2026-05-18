SLO Definitions
Overview
This document defines the Service Level Indicators (SLIs) and Service Level Objectives (SLOs) for the HNG DevOps Sandbox Platform. These definitions form the foundation of our reliability engineering practice and drive our alerting, dashboards, and error budget policy.

What is an SLI?
A Service Level Indicator is a quantitative measure of some aspect of the service. It is a real number produced by measuring something specific about how the service is behaving right now.

What is an SLO?
A Service Level Objective is a target value for an SLI. It is the reliability promise we make to ourselves and our users. If the SLI drops below the SLO target we have violated our reliability standard.

SLO 1 — Availability
Definition
The percentage of HTTP probes that return a 2xx response over a rolling 30-day window.

Why This Matters
Availability tells us whether users can actually reach the service. A service that returns errors or times out is not available even if the server itself is running.

SLI Expression (PromQL)
avg_over_time(probe_success[5m])

SLO Target
99.5% of HTTP probes must return 2xx over a rolling 30-day window

Error Budget Calculation
Error Budget = (1 - 0.995) x 43,200 minutes = 0.005 x 43,200 = 216 minutes of allowed downtime per month

Rationale
99.5% is appropriate for an internal platform. It gives us 216 minutes of downtime per month for planned maintenance and unexpected incidents while still holding us to a high standard. A stricter target like 99.9% would leave only 43 minutes per month which is too aggressive for a team of our size.

SLO 2 — Latency
Definition
The percentage of HTTP requests that complete in under 500ms over a rolling 30-day window.

Why This Matters
A service can be available but still unusable if it responds too slowly. Latency directly affects user experience. A user waiting more than 500ms for a response will notice the delay.

SLI Expression (PromQL)
histogram_quantile( 0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le) )

SLO Target
95% of requests must complete in under 500ms over a rolling 30-day window

Error Budget Calculation
Error Budget = (1 - 0.95) x total requests = 5% of requests allowed to exceed 500ms

Rationale
The 95th percentile at 500ms is the industry standard starting point for web services. We will tighten this SLO as we optimise the service.

SLO 3 — Error Rate
Definition
The percentage of HTTP requests that succeed (non 5xx response) over a rolling 30-day window.

Why This Matters
Errors directly impact users. A request that returns a 500 error means the user got nothing useful.

SLI Expression (PromQL)
1 - ( sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) )

SLO Target
99% of requests must succeed (non 5xx) over a rolling 30-day window

Error Budget Calculation
Error Budget = (1 - 0.99) x total requests = 1% of requests allowed to fail

Rationale
99% success rate means we tolerate 1 failure per 100 requests. We will tighten this to 99.5% as we gain confidence in our reliability.

Summary Table
SLO	Target	Error Budget	Window
Availability	99.5% uptime	216 minutes downtime	30 days
Latency	95% under 500ms	5% of requests may be slow	30 days
Error Rate	99% success	1% of requests may fail	30 days
Review Schedule
SLOs are reviewed monthly by the team. Reviews cover:

Did we meet each SLO target last month?
How much error budget was consumed?
Should any targets be tightened or relaxed?
Are there new SLIs we should be tracking?
Last updated: May 2026 Owner: DevOps Team