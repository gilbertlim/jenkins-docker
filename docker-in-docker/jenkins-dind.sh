#!/bin/bash

# https://www.jenkins.io/doc/book/installing/docker/
docker network create jenkins

docker run \
  --name docker-dind \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume $(dirname $(realpath $0))/jenkins:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client \
  --publish 2376:2376 \
  docker:dind \
  --storage-driver overlay2

docker build \
  --build-arg ARCHITECTURE=$(docker version --format '{{.Server.Arch}}') \
  -t jenkins:dind .

docker run \
  --name jenkins-master-dind \
  --restart=on-failure \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8081:8080 \
  --publish 50001:50000 \
  --volume $(dirname $(realpath $0))/jenkins:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  --env JAVA_OPTS="-Xms1024m -Xmx1024m" \
  jenkins:dind
