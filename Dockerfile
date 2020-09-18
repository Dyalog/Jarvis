FROM dyalog/dyalog:18.0
USER root

ADD . /opt/mdyalog/Jarvis

EXPOSE 8080
ADD Docker/run /entrypoint
USER dyalog
