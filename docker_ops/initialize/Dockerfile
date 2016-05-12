FROM alpine:3.3

MAINTAINER Raphael Ahrens

VOLUME ["/opt/volumes/", "/opt/input"]

RUN apk update && apk add python3 git openssl openjdk8-jre

RUN python3 -m ensurepip && pip3 install --upgrade pip setuptools

RUN pip install git+https://github.com/tantSinnister/rework.git
RUN pip install git+https://github.com/tantSinnister/psst.git
RUN pip install git+https://github.com/tantSinnister/bob_cert_builder.git


ADD init /root/init

RUN chmod +x /root/init

CMD ["/root/init"]
