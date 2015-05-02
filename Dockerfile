FROM centos:6.6
MAINTAINER allxone@hotmail.com

ENV ds_maven 3.3.1
ENV ds_cdh 2.6.0-cdh5.4.0
ENV ds_spark 1.3.0

# Prerequisites
RUN yum -y install wget tar bzip2 yum-plugin-priorities krb5-workstation && \
    yum clean all

# Oracle JDK 7u75
RUN wget --quiet --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u75-b13/jdk-7u75-linux-x64.rpm" && \
    rpm -Uvh jdk-7u75-linux-x64.rpm && rm -f jdk-7u75-linux-x64.rpm && \
    ln -s /usr/java/jdk1.7.0_75 /usr/java/default && \
    /usr/sbin/alternatives --install "/usr/bin/java" "java" "/usr/java/default/bin/java" 3 && \
    /usr/sbin/alternatives --install "/usr/bin/javac" "javac" "/usr/java/default/bin/javac" 3 && \
    echo "export JAVA_HOME=/usr/java/default" >> /etc/profile.d/custom.sh && \
    echo "export PATH=$JAVA_HOME/bin:$PATH" >> /etc/profile.d/custom.sh && \
    chmod +x /etc/profile.d/custom.sh
ENV JAVA_HOME /usr/java/default

# CDH Hadoop Client
RUN wget --quiet http://archive-primary.cloudera.com/cdh5/redhat/6/x86_64/cdh/cloudera-cdh5.repo && \
    echo 'priority = 98' >> cloudera-cdh5.repo && \
    mv cloudera-cdh5.repo /etc/yum.repos.d && \
    yum -y install hadoop-client && \
    yum clean all
ENV HADOOP_CONF_DIR /etc/hadoop/conf

# Maven
RUN mkdir -p /usr/local/apache-maven && \
    curl http://mirror.nohup.it/apache/maven/maven-3/$ds_maven/binaries/apache-maven-$ds_maven-bin.tar.gz | tar xz -C /usr/local && \
    echo "export M2_HOME=/usr/local/apache-maven-$ds_maven" >> /etc/profile.d/custom.sh && \
    echo "export M2=$M2_HOME/bin" >> /etc/profile.d/custom.sh && \
    echo "export MAVEN_OPTS=\"-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m\"" >> /etc/profile.d/custom.sh && \
    chmod +x /etc/profile.d/custom.sh

# Spark
RUN curl http://mirror.nohup.it/apache/spark/spark-$ds_spark/spark-$ds_spark.tgz | tar xz -C /usr/local && \
    cd /usr/local/spark-$ds_spark && \
    export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m" && \
    build/mvn -Pyarn -Phadoop-2.4 -Dhadoop.version=$ds_cdh -Phive -Phive-0.13.1 -Phive-thriftserver -DskipTests clean package
    echo "export SPARK_HOME=/usr/local/spark-$ds_spark" >> /etc/profile.d/custom.sh && \
    echo "export PATH=$SPARK_HOME/bin:$PATH" >> /etc/profile.d/custom.sh && \
    chmod +x /etc/profile.d/custom.sh
VOLUME /etc/hadoop

ENTRYPOINT /bin/bash
