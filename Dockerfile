FROM amazoncorretto:11 AS hail_build
ARG HAIL_VERSION=0.2.115
ARG SPARK_VERSION=3.4.1
ARG SCALA_VERSION=2.12.13


RUN yum -y update && yum install -y wget tar gzip gcc make openssl-devel bzip2-devel libffi-devel zlib-devel
#RUN yum -y install yum-utils git gcc-c++ openblas-devel lapack-devel lz4-devel python3 python3-pip rsync
RUN yum -y install yum-utils git gcc-c++ openblas-devel lapack-devel lz4-devel rsync && yum clean all
#RUN yum -y groupinstall development

# Python 버전 설정
RUN if [ $(echo "$HAIL_VERSION <= 0.2.115" | bc -l) -eq 1 ]; then \
        PYTHON_VERSION=3.7.15; \
    elif [ $(echo "$HAIL_VERSION <= 0.2.120" | bc -l) -eq 1 ]; then \
        PYTHON_VERSION=3.8.19; \
    else \
        PYTHON_VERSION=3.9.19; \
    fi && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make install && \
    cd .. && \
    rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}.tgz

# Create our virtual environment
# we need both --copies for python executables for cp for libraries
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV --copies
RUN cp -r /usr/local/lib/python*/* $VIRTUAL_ENV/lib/python*/

# Ensure our python3 executable references the virtual environment
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Upgrade pip (good practice) and install venv-pack
# You can install additional packages here or copy requirements.txt
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install venv-pack==0.2.0

RUN python3 -m pip install build
RUN python3 -m pip install uv

RUN git clone https://github.com/hail-is/hail.git /hail
WORKDIR /hail/hail
RUN git checkout tags/${HAIL_VERSION}

RUN make install-on-cluster HAIL_COMPILE_NATIVES=1 SCALA_VERSION=${SCALA_VERSION} SPARK_VERSION=${SPARK_VERSION}

# Package the env
# note you have to supply --python-prefix option to make sure python starts with the path where your copied libraries are present
RUN mkdir /output && \
    venv-pack -o /output/pyspark_hail_python.tar.gz --python-prefix /home/hadoop/environment

FROM scratch AS export
COPY --from=hail_build /output/pyspark_hail_python.tar.gz /
COPY --from=hail_build /opt/venv/lib/python3.*/site-packages/hail/backend/hail-all-spark.jar /
