#!/bin/bash
set -e

RELEASE=$1
if [ -z "$RELEASE" ]; then
  echo "Usage: ./switch.sh <release-name>"
  exit 1
fi

echo "🌀 Switching service to release: $RELEASE..."

kubectl patch service info-api-service -p \
  "{\"spec\": {\"selector\": {\"app\": \"info-api\", \"release\": \"$RELEASE\"}}}"

echo "$RELEASE" > active-release.txt
echo "✅ Switched to $RELEASE"

