# This image provides a Spark 2.4.0 + Python3.6 + Scala 2.11.8 environment
# Copyright 2017 Red Hat
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ------------------------------------------------------------------------
#
# This is a Dockerfile for the mapsacosta/spark-scala-py36:2.4.0 image: docker pull mapsacosta/spark-scala-py36:2.4.0

FROM centos:latest

USER root

# Install required RPMs and ensure that the packages were installed
RUN yum install -y java-1.8.0-openjdk wget which \
    && yum clean all && rm -rf /var/cache/yum \
    && rpm -q java-1.8.0-openjdk wget


# Add all artifacts to the /tmp/artifacts
# directory
COPY spark-2.4.3-bin-hadoop2.7.tgz /tmp/artifacts/
COPY sbt-0.13.13.tgz /tmp/artifacts/
COPY scala-2.12.0.tgz /tmp/artifacts/

# Environment variables
ENV \
    JBOSS_IMAGE_NAME="radanalyticsio/openshift-spark" \
    JBOSS_IMAGE_VERSION="2.4-latest" \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin" \
    SCL_ENABLE_CMD="scl enable rh-python36" \
    SPARK_HOME="/opt/spark" \
    SPARK_INSTALL="/opt/spark-distro" \
    STI_SCRIPTS_PATH="/usr/libexec/s2i" \ 
    SCALA_VERSION=2.12.0 \
    PATH=$HOME/.local/bin:/opt/scala/bin:/opt/sbt/bin:$PATH

# Labels
LABEL \
      io.cekit.version="2.2.7"  \
      io.openshift.s2i.scripts-url="image:///usr/libexec/s2i"  \
      maintainer="Maria A. <macosta[at]fnal.gov>"  \
      name="mapsacosta/openshift-spark"  \
      org.concrt.version="2.2.7"  \
      sparkversion="2.4.3"  \
      version="2.4.3-latest" 

# Add scripts used to configure the image
COPY modules /tmp/scripts

# Copy extra files to the image.
COPY ./root/ /

# Custom scripts
USER root
RUN [ "bash", "-x", "/tmp/scripts/common/install" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/metrics/install" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/spark/install" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/s2i/install" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/python36/install" ]

#Install sbt and Scala

USER root
RUN bash -x /opt/app-root/check_for_download_sbt /tmp/artifacts/sbt-0.13.13.tgz && \
    bash -x /opt/app-root/check_for_download_scala /tmp/artifacts/scala-2.12.0.tgz && \
    tar -zxf /tmp/artifacts/sbt-0.13.13.tgz -C /opt && \
    ln -s /opt/sbt-launcher-packaging-0.13.13 /opt/sbt && \
    tar -zxf /tmp/artifacts/scala-2.12.0.tgz -C /opt && \
    ln -s /opt/scala-2.12.0.tgz /opt/scala && \
    mkdir /tmp/.ivy2 /tmp/.sbt && \
    /opt/sbt/bin/sbt

# - In order to drop the root user, we have to make some directories world
#   writable as OpenShift default security model is to run the container
#   under random UID.
RUN chown -R 1001:0 /opt/app-root && \
    chown -R 1001:0 /opt/sbt && \
    chown -R 1001:0 /opt/scala && \
    chmod g+rw /opt/sbt/conf && \
    chown -R 1001:0 /tmp/.ivy2 && \
    chmod g+rw /tmp/.ivy2 && \
    chown -R 1001:0 /tmp/.sbt && \
    chmod g+rw /tmp/.sbt  

RUN pip3 install --no-cache-dir pyspark==2.4.3

#Installing (Apache Arrow + gcc)
WORKDIR /

USER root
ENV ARROW_HOME=/usr/local
ENV PARQUET_HOME=/usr/local

RUN [ "bash", "-x", "/tmp/scripts/coffea/install" ]

#Some cleanup
RUN rm -rf /tmp/scripts
USER root
RUN rm -rf /tmp/artifacts

#Additional python libs
RUN pip3 install --no-cache-dir --upgrade pip
RUN pip3 install --no-cache-dir py4j
RUN pip3 install --no-cache-dir scipy
RUN pip3 install --no-cache-dir jinja2
RUN pip3 install --no-cache-dir cloudpickle
RUN pip3 install --no-cache-dir lz4

#Installing llvm from yum
RUN yum install -y devtoolset-7 llvm-toolset-7 \
    && yum install -y llvm-toolset-7-clang-analyzer llvm-toolset-7-clang-tools-extra # optional

#Finish up with numba and coffea install
RUN pip3 install --no-cache-dir numba
RUN pip3 install --no-cache-dir coffea

# Specify the working directory
WORKDIR /tmp

ENTRYPOINT ["/entrypoint"]

CMD ["/launch.sh"]

USER 185
