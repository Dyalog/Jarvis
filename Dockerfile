FROM dyalog/dyalog:19.0
USER root

ADD . /opt/mdyalog/Jarvis

EXPOSE 8080
ENV VERSION=19.0
ADD Docker/entrypoint /entrypoint
USER dyalog
