# Don't use fedora here, ncat will fail
# See https://github.com/nmap/nmap/issues/1410
FROM ubuntu:latest

ENV NCAT_MESSAGE "Container test"
ENV NCAT_HEADER "HTTP/1.1 200 OK"
ENV NCAT_PORT "8888"

RUN apt-get update && \
    apt-get install -y nmap && \
    apt-get clean

CMD /usr/bin/ncat -l $NCAT_PORT -k -c "echo $NCAT_HEADER; echo; echo $NCAT_MESSAGE"

EXPOSE $NCAT_PORT
