#!/bin/bash
set -e

CURRENT=$(cat active-release.txt)
ACTIVE_DEPLOYMENT="info-api-$CURRENT"

echo "ℹ️ Active release (from file): $CURRENT"

SERVICE_RELEASE=$(kubectl get service info-api-service -o jsonpath="{.spec.selector.release}")

if [ "$SERVICE_RELEASE" != "$CURRENT" ]; then
  echo "❌ ERROR: Service is routing traffic to '$SERVICE_RELEASE', not to active release '$CURRENT'."
  echo "❌ Finalization aborted."
  exit 1
fi

echo "✅ Service is correctly routing traffic to $CURRENT."

CURRENT_NUM=${CURRENT#v}

# Удаляем только деплойменты и поды старше активного релиза
DEPLOYS=$(kubectl get deployments -l app=info-api -o jsonpath="{.items[*].metadata.name}" | tr ' ' '\n')
PODS=$(kubectl get pods -l app=info-api -o jsonpath="{.items[*].metadata.name}" | tr ' ' '\n')

OLD_FOUND=0

for d in $DEPLOYS; do
  REL=$(echo $d | sed 's/info-api-//')
  REL_NUM=${REL#v}
  if [ "$REL_NUM" -lt "$CURRENT_NUM" ]; then
    echo "✅ Deleting old deployment: $d"
    kubectl delete deployment $d
    OLD_FOUND=1
  fi
done

for p in $PODS; do
  REL=$(kubectl get pod $p -o jsonpath="{.metadata.labels.release}")
  REL_NUM=${REL#v}
  if [ "$REL_NUM" -lt "$CURRENT_NUM" ]; then
    echo "✅ Deleting old pod: $p"
    kubectl delete pod $p || true
    OLD_FOUND=1
  fi
done

if [ "$OLD_FOUND" -eq 0 ]; then
  echo "ℹ️ No old releases found to delete."
fi

