#!/bin/bash

APPLICATION_ID=$(cat applicationId.txt | tr -d '\n')

aws emr-serverless start-application \
        --application-id $APPLICATION_ID
