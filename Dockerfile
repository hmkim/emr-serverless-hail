FROM --platform=linux/amd64 public.ecr.aws/amazonlinux/amazonlinux:2023-minimal AS base

ARG HAIL_VERSION=0.2.134
ARG SPARK_VERSION=3.5.4
ARG SCALA_VERSION=2.12.18

RUN dnf install -y gcc python3 python3-devel git gcc-c++ openblas-devel lapack-devel lz4-devel rsync

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN python3 -m pip install --upgrade pip && \
python3 -m pip install \
hail==$HAIL_VERSION \
venv-pack==0.2.0

RUN mkdir /output && venv-pack -o /output/pyspark_hail.tar.gz

FROM scratch AS export
COPY --from=base /output/pyspark_hail.tar.gz /
COPY --from=base /opt/venv/lib/python3.*/site-packages/hail/backend/hail-all-spark.jar /
