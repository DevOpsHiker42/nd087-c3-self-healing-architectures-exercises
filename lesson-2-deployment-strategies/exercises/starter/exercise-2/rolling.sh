#!/bin/bash
set -e
kubectl set image deployment nginx-rolling nginx=nginx:1.21.1
# Monitor the deployment every second as it rolls out
ATTEMPTS=0
ROLLOUT_STATUS_CMD="kubectl rollout status deployment/nginx-rolling -n udacity"
until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
$ROLLOUT_STATUS_CMD
ATTEMPTS=$((attempts + 1))
sleep 1
echo "Deployment still rolling out..."
done
# All done
echo "ALL DONE - Deployment Complete!"
