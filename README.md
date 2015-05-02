# HADOOP-CLIENT

# RUN
1) Create an empty folder
2) copy /etc/hadoop .
3) copy /etc/krb5.conf .
4) Create Dockerfile with this content
FROM allxone/hadoop_client
ADD krb5.conf /etc/krb5.conf
ADD hadoop /etc/hadoop/

5) Build your Docker image
docker build -t your_hadoop_client

6) Launch your container
docker run -it your_hadoop_client
