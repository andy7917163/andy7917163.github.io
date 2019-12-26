FROM node:alpine

RUN apk update && apk upgrade && \
    apk add --no-cache git

WORKDIR /home

VOLUME ["/home"]

RUN npm install hexo-cli -g

EXPOSE 4000

CMD []