FROM dyalog/dyalog:18.2
USER root

ADD . /opt/mdyalog/Jarvis

EXPOSE 8080
ADD Docker/entrypoint /entrypoint
USER dyalog
