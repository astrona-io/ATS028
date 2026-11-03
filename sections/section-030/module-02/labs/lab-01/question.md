# Task: Select Workloads And Record What You Find

The namespace `starfleet` runs three Deployments (`probe`, `beacon`, `scout`), a client pod `shuttle` and a Job `report-job` that has already finished. A teammate asks for a short report and a review mark. Use `kubectl` selectors and output formats; do not read pod names by eye from a long listing.

## Requirements

1. Create a ConfigMap named `findings` in `starfleet` with these three keys:
   - `web-pods`: the names of all pods that have the labels `tier=web` and `env=prod`, one name per line, without the `pod/` prefix.
   - `images`: every distinct container image used by the pods in `starfleet`, one per line.
   - `completed-pod`: the name of the pod whose phase is `Succeeded`.
2. Add the label `reviewed=true` to the pods listed in `web-pods`, and to no other pod.
3. Do not delete, scale or change any Deployment. The `probe` Service must keep answering.

## How to check your work

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS028.git -c sections/section-030/module-02/labs/lab-01
```

Each check prints PASS or a FAIL line that names the difference. Fix it and submit again.
