#!/bin/bash


if [ $# -eq 0 ]; then
    echo "Usage: $0 <S3_BUCKET_NAME>"
    exit 1
fi

S3_BUCKET=$1

HAIL_VERSION=0.2.100
SPARK_VERSION=3.2.1
SCALA_VERSION=2.12.13

echo "DOCKER_BUILDKIT=1 docker build --build-arg HAIL_VERSION=${HAIL_VERSION} --build-arg SPARK_VERSION=${SPARK_VERSION} --build-arg SCALA_VERSION=${SCALA_VERSION} --output ./out_files ." 
DOCKER_BUILDKIT=1 docker build --build-arg HAIL_VERSION=${HAIL_VERSION} --build-arg SPARK_VERSION=${SPARK_VERSION} --build-arg SCALA_VERSION=${SCALA_VERSION} --output ./out_files .

aws s3 mv out_files/pyspark_hail.tar.gz     s3://${S3_BUCKET}/artifacts/pyspark/pyspark_hail.tar.gz
aws s3 cp ../hail-script-example.py           s3://${S3_BUCKET}/code/pyspark/
aws s3 cp ../hail-script-onlyHail.py           s3://${S3_BUCKET}/code/pyspark/
aws s3 mv out_files/hail-all-spark.jar s3://${S3_BUCKET}/artifacts/pyspark/
