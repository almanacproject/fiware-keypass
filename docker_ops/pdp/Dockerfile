FROM java:alpine

MAINTAINER Raphael Ahrens

ADD keypassPDP.jar /opt/keypass/keypassPDP.jar
ADD wait-for-it.sh /opt/keypass/wait-for-it.sh
RUN chmod +x /opt/keypass/wait-for-it.sh
ADD start /opt/keypass/start
RUN chmod +x /opt/keypass/start

CMD ["/opt/keypass/start"]

EXPOSE 8443
