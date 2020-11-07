FROM ubuntu:20.04

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
 cmake \
 make \
 g++ \
 zlib1g-dev \
 libjpeg-dev \
 libpng-dev \
 freeglut3-dev \
 libxml2-dev \
 libxxf86vm-dev \
 netpbm \
 exiftool \
 bc 

WORKDIR /codes
ENTRYPOINT /codes/run.sh
