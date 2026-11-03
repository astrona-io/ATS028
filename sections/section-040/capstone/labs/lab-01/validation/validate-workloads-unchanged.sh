#!/usr/bin/env bash
# Check: the gauge writer container, the manifest Deployment and the valve Deployment keep their original settings.
set -uo pipefail

fail=0
img='docker.io/library/busybox:1.37.0'
g="$(kubectl -n starfleet get deployment gauge -o jsonpath='{.spec.template.spec.containers[?(@.name=="writer")].image}' 2>/dev/null || true)"
gc="$(kubectl -n starfleet get deployment gauge -o jsonpath='{.spec.template.spec.containers[?(@.name=="writer")].command}' 2>/dev/null || true)"
gr="$(kubectl -n starfleet get deployment gauge -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
mr="$(kubectl -n starfleet get deployment manifest -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
mn="$(kubectl -n starfleet get deployment manifest -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null || true)"
vn="$(kubectl -n starfleet get deployment valve -o jsonpath='{.spec.template.spec.containers[*].name}' 2>/dev/null || true)"

[ "$g" = "$img" ] || { echo "FAIL: the gauge writer container must keep the image $img (found: ${g:-no writer container})"; fail=1; }
case "$gc" in
  *"/var/log/gauge/gauge.log"*"gauge-reading"*|*"gauge-reading"*"/var/log/gauge/gauge.log"*) ;;
  *) echo "FAIL: the gauge writer container must keep its command that appends gauge-reading lines to /var/log/gauge/gauge.log"; fail=1 ;;
esac
[ "$gr" = "1" ] || { echo "FAIL: the gauge Deployment must keep 1 replica (found: ${gr:-none})"; fail=1; }
[ "$mr" = "3" ] || { echo "FAIL: the manifest Deployment must keep 3 replicas (found: ${mr:-none})"; fail=1; }
[ "$mn" = "web audit" ] || { echo "FAIL: the manifest Deployment must keep its containers web and audit (found: ${mn:-none})"; fail=1; }
[ "$vn" = "app" ] || { echo "FAIL: the valve Deployment must keep its container app (found: ${vn:-none})"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: the gauge writer, the manifest Deployment and the valve Deployment are unchanged"
exit "$fail"
