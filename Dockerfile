FROM dyalog/dyalog
USER root

ADD . /opt/mdyalog/Jarvis

EXPOSE 8080
ADD Docker/run /entrypoint
USER dyalog
