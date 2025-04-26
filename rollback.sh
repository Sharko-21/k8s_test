#!/bin/bash
set -e

CURRENT=$(cat active-release.txt)
DEPLOYS=$(kubectl get deployments -l app=info-api -o jsonpath="{.items[*].metadata.name}" | tr ' ' '\n')

PREVIOUS=""
for d in $DEPLOYS; do
  REL=$(echo $d | sed 's/info-api-//')
  if [ "$REL" != "$CURRENT" ]; then
    PREVIOUS=$REL
    break
  fi
done

if [ -z "$PREVIOUS" ]; then
  echo "⚠️ No previous release found."
  exit 1
fi

echo "🔁 Rolling back to $PREVIOUS..."

./switch.sh $PREVIOUS
kubectl delete deployment info-api-$CURRENT
echo "$PREVIOUS" > active-release.txt
echo "✅ Rolled back to $PREVIOUS"

