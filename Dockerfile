# This image provides a Spark 2.4.0 + Python3.6 + Scala 2.11.8 environment
# ------------------------------------------------------------------------
# The image was modified to fit OKD and COFFEA requirements for Spark analysis
# @author: Maria A. - FNAL
# DockerHub repository: mapsacosta/spark-scala-py36:2.4.0 image: docker pull mapsacosta/spark-scala-py36:2.4.3

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

# Environment variables
ENV \
    JBOSS_IMAGE_NAME="radanalyticsio/openshift-spark" \
    JBOSS_IMAGE_VERSION="2.4-latest" \
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/spark/bin" \
    SCL_ENABLE_CMD="scl enable rh-python36" \
    SPARK_HOME="/opt/spark" \
    SPARK_INSTALL="/opt/spark-distro" \
    STI_SCRIPTS_PATH="/usr/libexec/s2i" \ 
    SCALA_VERSION=2.11.8 \
    PATH=$HOME/.local/bin:/opt/sbt/bin:$PATH

# Labels
LABEL \
      io.cekit.version="2.2.7"  \
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
RUN [ "bash", "-x", "/tmp/scripts/python36/install" ]

USER root
RUN [ "bash", "-x", "/tmp/scripts/spark/install" ]

#Put hadoop in

RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-2.7.2/hadoop-2.7.2.tar.gz && tar xvf hadoop-2.7.2.tar.gz  -C /opt/
COPY modules/hadoop/* /opt/hadoop-2.7.2/etc/hadoop/

#Install sbt

USER root
RUN bash -x /opt/app-root/check_for_download_sbt /tmp/artifacts/sbt-0.13.13.tgz && \
    tar -zxf /tmp/artifacts/sbt-0.13.13.tgz -C /opt && \
    ln -s /opt/sbt-launcher-packaging-0.13.13 /opt/sbt && \
    mkdir /tmp/.ivy2 /tmp/.sbt 

#Installing (Apache Arrow + gcc)
WORKDIR /

USER root
ENV ARROW_HOME=/usr/local
ENV PARQUET_HOME=/usr/local

RUN pip3 install --no-cache-dir --upgrade pip 
RUN pip3 install --no-cache-dir setuptools
RUN pip3 install --no-cache-dir numpy==1.14.5
RUN pip3 install --no-cache-dir numpy six pytest numpy cython
RUN pip3 install --no-cache-dir pandas

RUN [ "bash", "-x", "/tmp/scripts/coffea/install" ]

#Some cleanup
RUN rm -rf /tmp/scripts
USER root
RUN rm -rf /tmp/artifacts

#Installing llvm from yum
RUN yum install -y devtoolset-7 llvm-toolset-7 \
    && yum install -y llvm-toolset-7-clang-analyzer llvm-toolset-7-clang-tools-extra # optional

#Finish up with python3 libs install
RUN pip3 install --no-cache-dir py4j 
RUN pip3 install --no-cache-dir scipy 
RUN pip3 install --no-cache-dir jinja2 
RUN pip3 install --no-cache-dir cloudpickle 
RUN pip3 install --no-cache-dir lz4

RUN pip install --no-cache-dir pyarrow==0.10.0
RUN pip install --no-cache-dir numba
RUN pip install --no-cache-dir coffea 

#Initializing runtime environment
#Python
ENV PYSPARK_PYTHON="python3.6"
ENV PYSPARK_MAJOR_PYTHON_VERSION="3"

#Spark
ENV SPARK_WORKER_DIR=/scratch
ENV SPARK_WORKER_PORT=8581
ENV SPARK_DIST_CLASSPATH="$(hadoop classpath)"
ENV PATH="$SPARK_HOME/bin:$PATH"

#Hadoop
ENV PATH="/opt/hadoop-2.7.3/bin:$PATH"
ENV HADOOP_HOME="/opt/hadoop-2.7.2"
ENV HADOOP_CLASSPATH="$HADOOP_HOME/libexec"
ENV PATH="$PATH:$HADOOP_HOME/bin:$JAVA_PATH/bin:$HADOOP_HOME/sbin"
ENV HADOOP_PREFIX="/opt/hadoop-2.7.2"
ENV HADOOP_MAPRED_HOME="${HADOOP_HOME}"
ENV HADOOP_COMMON_HOME="${HADOOP_HOME}"
ENV HADOOP_HDFS_HOME="${HADOOP_HOME}"
ENV YARN_HOME="${HADOOP_HOME}"
ENV HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"
ENV HADOOP_COMMON_LIB_NATIVE_DIR="${HADOOP_PREFIX}/lib/native"
ENV HADOOP_OPTS="$HADOOP_OPTS -Djava.library.path=$HADOOP_HOME/lib/native"
ENV LD_LIBRARY_PATH="$HADOOP_HOME/lib/native/:$LD_LIBRARY_PATH"

#Putting hadoop-xrootd connector in place and modifying classpath
COPY modules/hadoop-xrootd/* /opt/hadoop-xrootd/
ENV HADOOP_CLASSPATH="/opt/hadoop-xrootd/*:$(hadoop classpath)"

#Installing xrootd requirements for HDFS connector
RUN yum -y install xrootd-client xrootd-client-libs xrootd-client-devel

#Installing OSG libs/CAs (WN client for now but we can prob get rid of a lot of this) 
RUN yum -y install https://repo.opensciencegrid.org/osg/3.4/osg-3.4-el7-release-latest.rpm \
                   epel-release \
                   yum-plugin-priorities && \
    yum -y install  \
                   osg-wn-client \
                   redhat-lsb-core \
                   singularity && \
    yum clean all && \
    rm -rf /var/cache/yum/*

WORKDIR /tmp
ENTRYPOINT ["/entrypoint"]

# - In order to drop the root user, we have to make some directories world
#   writable as OpenShift default security model is to run the container
#   under random UID.
RUN chown -R 1001:0 /opt/app-root && \
    chown -R 1001:0 /opt/sbt && \
    chmod g+rw /opt/sbt/conf && \
    chown -R 1001:0 /tmp/.ivy2 && \
    chmod g+rw /tmp/.ivy2 && \
    chown -R 1001:0 /tmp/.sbt && \
    chmod g+rw /tmp/.sbt  

USER root
VOLUME ["/scratch"]
RUN chmod -R 0777 /scratch

CMD ["/launch.sh"]
USER 185
