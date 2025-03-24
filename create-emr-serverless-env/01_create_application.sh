#!/bin/bash


aws emr-serverless create-application \
  --type SPARK \
  --name hail-app \
  --release-label "emr-7.1.0" \
    --initial-capacity '{
        "DRIVER": {
            "workerCount": 2,
            "workerConfiguration": {
                "cpu": "4vCPU",
                "memory": "16GB"
            }
        },
        "EXECUTOR": {
            "workerCount": 10,
            "workerConfiguration": {
                "cpu": "4vCPU",
                "memory": "16GB"
            }
        }
    }' \
    --maximum-capacity '{
        "cpu": "200vCPU",
        "memory": "200GB",
        "disk": "1000GB"
    }' \
    --query 'applicationId' \
    --output text > applicationId.txt

