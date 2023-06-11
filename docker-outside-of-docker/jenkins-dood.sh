docker run \
  --name jenkins-master-dood \
  --restart=on-failure \
  --detach \
  --user root \
  --publish 8082:8080 \
  --publish 50002:50000 \
  --volume $(dirname $(realpath $0))/jenkins:/var/jenkins_home \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  jenkins:lts
