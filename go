#!/bin/sh
docker kill ucislave_$1
docker rm ucislave_$1
docker build -t mblow/ucislave-centos7
docker run -p $1:22 mblow/ucislave-centos7 --name ucislave_$1
