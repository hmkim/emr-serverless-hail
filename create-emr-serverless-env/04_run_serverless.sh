#!/bin/bash

APPLICATION_ID=$(cat applicationId.txt | tr -d '\n')

if [ $# -eq 0 ]; then
    echo "Usage: $0 <job role ARN> <S3_BUCKET_NAME>"
    exit 1
fi


JOB_ROLE_ARN=$1
S3_BUCKET=$2

aws emr-serverless start-job-run \
    --application-id $APPLICATION_ID \
    --execution-role-arn $JOB_ROLE_ARN \
    --job-driver '{
        "sparkSubmit": {
            "entryPoint": "s3://'${S3_BUCKET}'/code/pyspark/hail-script-example.py",
            "entryPointArguments": ["-a", "environment", "-o", "s3://'${S3_BUCKET}'/outputs/test.ht", "-t", "s3://'${S3_BUCKET}'/tmp"],
            "sparkSubmitParameters": "--conf spark.archives=s3://'${S3_BUCKET}'/artifacts2/pyspark/hail/pyspark_hail.tar.gz#environment --conf spark.emr-serverless.driverEnv.PYSPARK_DRIVER_PYTHON=./environment/bin/python --conf spark.emr-serverless.driverEnv.PYSPARK_PYTHON=./environment/bin/python --conf spark.executorEnv.PYSPARK_PYTHON=./environment/bin/python --jars s3://'${S3_BUCKET}'/artifacts2/pyspark/hail/hail-all-spark.jar"
        } 
    }' \
    --configuration-overrides '{
		    "applicationConfiguration": [{
            "classification": "spark-defaults",
            "properties": {
                "spark.serializer": "org.apache.spark.serializer.KryoSerializer",
                "spark.kryo.registrator": "is.hail.kryo.HailKryoRegistrator"
            }
        }],
        "monitoringConfiguration": {
            "s3MonitoringConfiguration": {
                "logUri": "s3://'${S3_BUCKET}'/logs/"
            }
        }
    }'


