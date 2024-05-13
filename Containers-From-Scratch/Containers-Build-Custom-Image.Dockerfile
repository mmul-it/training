FROM alpine:latest

ENV NCAT_MESSAGE "Container test"                                               
ENV NCAT_HEADER "HTTP/1.1 200 OK"                                               
ENV NCAT_PORT "8888" 

RUN apk add bash nmap-ncat

CMD /usr/bin/ncat -l $NCAT_PORT -k -c "echo '$NCAT_HEADER'; echo; echo $NCAT_MESSAGE"

EXPOSE $NCAT_PORT
