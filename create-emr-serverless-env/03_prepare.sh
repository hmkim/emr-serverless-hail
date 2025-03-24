#!/bin/bash


S3_BUCKET={MY_BUCKET}

HAIL_VERSION=0.2.100
SPARK_VERSION=3.2.1

git clone https://github.com/hmkim/emr-serverless-hail
cd emr-serverless-hail

DOCKER_BUILDKIT=1 docker build --build-arg HAIL_VERSION=${HAIL_VERSION} --build-arg SPARK_VERSION=${SPARK_VERSION} --output ./out_files .

aws s3 mv out_files/pyspark_hail.tar.gz     s3://${S3_BUCKET}/artifacts/pyspark/pyspark_hail.tar.gz
aws s3 cp hail-script-example.py           s3://${S3_BUCKET}/code/pyspark/
aws s3 mv out_files/hail-all-spark.jar s3://${S3_BUCKET}/artifacts/pyspark/
