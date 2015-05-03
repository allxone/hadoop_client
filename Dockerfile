FROM centos:6.6
MAINTAINER allxone@hotmail.com

ENV ds_maven 3.3.1
ENV ds_cdh 2.6.0-cdh5.4.0
ENV ds_spark 1.3.0

# Prerequisites
RUN yum -q -y install wget tar bzip2 yum-plugin-priorities krb5-workstation && \
    yum clean all

# Oracle JDK 7u75
RUN wget --quiet --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u75-b13/jdk-7u75-linux-x64.rpm" && \
    rpm -Uvh jdk-7u75-linux-x64.rpm && rm -f jdk-7u75-linux-x64.rpm && \
    ln -s /usr/java/jdk1.7.0_75 /usr/java/default && \
    /usr/sbin/alternatives --install "/usr/bin/java" "java" "/usr/java/default/bin/java" 3 && \
    /usr/sbin/alternatives --install "/usr/bin/javac" "javac" "/usr/java/default/bin/javac" 3
ENV JAVA_HOME /usr/java/default

# CDH Hadoop Client
RUN wget --quiet http://archive-primary.cloudera.com/cdh5/redhat/6/x86_64/cdh/cloudera-cdh5.repo && \
    echo 'priority = 98' >> cloudera-cdh5.repo && \
    mv cloudera-cdh5.repo /etc/yum.repos.d && \
    yum -q -y install hadoop-client && \
    yum clean all
ENV HADOOP_CONF_DIR /etc/hadoop/conf

# Spark
ENV SPARK_HOME /usr/local/spark-$ds_spark
RUN curl http://mirror.nohup.it/apache/spark/spark-$ds_spark/spark-$ds_spark.tgz | tar xz -C /usr/local && \
    cd /usr/local/spark-$ds_spark && \
    export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m" && \
    build/mvn -Pyarn -Phadoop-2.4 -Dhadoop.version=$ds_cdh -Phive -Phive-thriftserver -DskipTests clean package

ENV PATH $JAVA_HOME/bin:$SPARK_HOME/bin:$PATH

