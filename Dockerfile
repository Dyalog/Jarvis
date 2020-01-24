FROM dyalog/dyalog

ADD Docker/run /
ADD . /Jarvis

RUN mkdir -p /app

EXPOSE 8080
