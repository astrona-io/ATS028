---
draft: true
exam_objectives:
- Implement probes and health checks
---
# Summary

Probes connect observed conditions to different actions. Startup allows initialization, readiness controls useful traffic eligibility and liveness can restart a failed container.

Checks need suitable endpoints, cost and timing. A shared dependency outage should not automatically restart every frontend, and an open listener does not guarantee that the application can fulfill its intended requests.

Health evidence has meaning through the action it controls. Startup gates regular probes, readiness controls traffic eligibility, and liveness can request a restart. Correct verification observes each corresponding state change separately.

<!-- astrona:playground:destroy -->
