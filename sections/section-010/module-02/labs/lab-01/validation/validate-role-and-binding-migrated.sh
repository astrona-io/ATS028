#!/usr/bin/env bash
# Check: the Role and RoleBinding exist, are readable in the supported version,
# and give scout-reader the read rights from the legacy file.
set -uo pipefail

SA="system:serviceaccount:starfleet:scout-reader"
fail=0

role_verbs="$(kubectl -n starfleet get roles.v1.rbac.authorization.k8s.io scout-reader -o jsonpath='{.rules[*].verbs[*]}' 2>/dev/null || true)"
if [ -z "$role_verbs" ]; then
  echo "FAIL: the Role scout-reader does not exist in starfleet"
  fail=1
fi

subject="$(kubectl -n starfleet get rolebindings.v1.rbac.authorization.k8s.io scout-reader -o jsonpath='{.subjects[0].kind}/{.subjects[0].name}/{.roleRef.kind}/{.roleRef.name}' 2>/dev/null || true)"
if [ "$subject" != "ServiceAccount/scout-reader/Role/scout-reader" ]; then
  echo "FAIL: the RoleBinding scout-reader must bind ServiceAccount scout-reader to Role scout-reader (found: ${subject:-nothing})"
  fail=1
fi

for resource in pods pods/log; do
  answer="$(kubectl auth can-i get "$resource" -n starfleet --as="$SA" 2>/dev/null || true)"
  if [ "$answer" != "yes" ]; then
    echo "FAIL: scout-reader cannot get $resource in starfleet"
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "PASS: Role and RoleBinding are migrated and scout-reader can read pods and logs"
fi
exit "$fail"
