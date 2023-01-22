#! /bin/bash
aws emr-serverless start-job-run \
    --application-id $APPLICATION_ID \
    --execution-role-arn $JOB_ROLE_ARN \
    --job-driver '{
        "sparkSubmit": {
            "entryPoint": "s3://'${S3_BUCKET}'/scripts/hail-script.py",
            "entryPointArguments": ["-a", "pyspark_hail", "-o", "s3://'${S3_BUCKET}'/outputs/test.ht", "-t", "s3://'${S3_BUCKET}'/tmp"],
            "sparkSubmitParameters": "--archives=s3://'${S3_BUCKET}'/resources/pyspark_hail.tar.gz#pyspark_hail --jars s3://'${S3_BUCKET}'/resources/hail-all-spark.jar"
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