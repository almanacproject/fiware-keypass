FROM centos:7

MAINTAINER IoT team

RUN yum update -y && yum install -y wget
# RUN wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
# RUN yum localinstall -y --nogpgcheck epel-release-6-8.noarch.rpm
RUN yum install -y rpm-build java-1.8.0-openjdk

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk.x86_64

## Install MySQL client
RUN yum -y install mysql

ADD keypassPAP-0.4.2.jar /opt/keypass/keypassPAP.jar

CMD java -jar /opt/keypass/keypassPAP.jar db migrate /opt/keypass/conf/config.yml && java -jar /opt/keypass/keypassPAP.jar server /opt/keypass/conf/config.yml

EXPOSE 8443
