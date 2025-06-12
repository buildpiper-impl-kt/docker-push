FROM docker:latest

ENV SLEEP_DURATION=5s

RUN apk add --no-cache jq bash

COPY build.sh .
RUN chmod +x build.sh
ADD BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/

ENTRYPOINT ["./build.sh"]