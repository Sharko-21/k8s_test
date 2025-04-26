#!/bin/bash
set -e

RELEASE=$1
if [ -z "$RELEASE" ]; then
  echo "Usage: ./release.sh <release-name>"
  exit 1
fi

IMAGE=info-api:$RELEASE
DEPLOY=info-api-$RELEASE
OUTFILE=deploys/${DEPLOY}.yaml

mkdir -p deploys

echo "📦 Building image $IMAGE..."
docker build -t $IMAGE .

echo "📦 Loading image into kind..."
kind load docker-image $IMAGE --name multi

echo "📝 Writing deployment to $OUTFILE..."
cat <<EOF > $OUTFILE
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOY
  labels:
    app: info-api
    release: $RELEASE
spec:
  replicas: 3
  selector:
    matchLabels:
      app: info-api
      release: $RELEASE
  template:
    metadata:
      labels:
        app: info-api
        release: $RELEASE
    spec:
      containers:
      - name: info-api
        image: $IMAGE
        imagePullPolicy: Never
        ports:
        - containerPort: 80
        env:
        - name: RELEASE
          value: "$RELEASE"
EOF

echo "🚀 Applying deployment..."
kubectl apply -f $OUTFILE

