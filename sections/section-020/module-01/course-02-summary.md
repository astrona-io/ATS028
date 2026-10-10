---
draft: true
exam_objectives:
- Implement probes and health checks
---
# Summary

Probes connect observed conditions to different actions. Startup allows initialization, readiness controls useful traffic eligibility and liveness can restart a failed container.

Checks need suitable endpoints, cost and timing. A shared dependency outage should not automatically restart every frontend, and an open listener does not guarantee that the application can fulfill its intended requests.
