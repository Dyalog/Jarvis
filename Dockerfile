FROM dyalog/techpreview:20.0
USER root

ADD . /opt/mdyalog/Jarvis

EXPOSE 8080
ADD Docker/entrypoint /entrypoint
USER dyalog
