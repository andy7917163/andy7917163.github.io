# Hexo development with docker

![author](https://img.shields.io/badge/Build-Andy-blue.svg)

## How to use

```shell=
docker build -t node:hexo .
docker run -it --rm -p 4000:4000 -v /$PWD:/home node:hexo npm install
docker run -it --rm -p 4000:4000 -v /$PWD:/home node:hexo hexo version
```