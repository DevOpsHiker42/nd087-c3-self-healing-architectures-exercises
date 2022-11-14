#!/bin/bash
#
# Script variables
#
DEPLOY_INCREMENT=2
#
# Functions
#
function canary_deploy {
  V1_POD_REPLICAS=`kubectl get pods -n udacity | grep -c canary-v1`
  echo "V1 pod replicas: " ${V1_POD_REPLICAS}
  V2_POD_REPLICAS=`kubectl get pods -n udacity | grep -c canary-v2`
  echo "V2 pod replicas: " ${V2_POD_REPLICAS}
  # Increment v2 replicas by DEPLOY_INCREMENT
  kubectl scale deployment canary-v2 --replicas=$((V2_POD_REPLICAS + DEPLOY_INCREMENT))
  # Decrement v1 replicas by DEPLOY_INCREMENT
  kubectl scale deployment canary-v1 --replicas=$((V1_POD_REPLICAS - DEPLOY_INCREMENT))
  # Monitor deployment
  monitor_v2_deploy
}
function manual_verification {
  read -p "Continue deployment? (y/n) " answer

    if [[ $answer =~ ^[Yy]$ ]] ;
    then
        echo "continuing deployment"
    else
        exit
    fi
}
function monitor_v2_deploy {
  # Monitor the deployment every second as it rolls out
  ATTEMPTS=0
  ROLLOUT_STATUS_CMD="kubectl rollout status deployment/canary-v2 -n udacity"
  until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 60 ]; do
    $ROLLOUT_STATUS_CMD
    ATTEMPTS=$((attempts + 1))
    sleep 1
    echo "Deployment still rolling out..."
  done
  echo "Canary deployment of $DEPLOY_INCREMENT replicas complete"
}
#
# Stage v2 deployment
#
kubectl apply -f canary-v2.yml
#
# Start canary deployment rollout
#
while [ $(kubectl get pods -n udacity | grep -c canary-v1) -gt 0 ]
do
   canary_deploy
   manual_verification
done

echo "ALL DONE: Canary deployment of v2 successful!"
