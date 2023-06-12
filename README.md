# Docker in Docker (DinD)

![jenkins dind](img/dind.png)

1. `cd docker-in-docker`
2. `./jenkins-dind.sh`
3. localhost:8081
4. `docker logs jenkins-master-dind` 후 초기 비밀번호 확인

<br>

# Docker outside of Docker (DooD)

![jenkins dind](img/dood.png)

1. `cd docker-outside-of-docker`
2. `./jenkins-dood.sh`
3. localhost:8082
4. `docker logs jenkins-master-dood` 후 초기 비밀번호 확인

<br>

# Jenkins Setting

## 1. Install Plugins (Manage Jenkins > Plugins > available plugins)
- Build Timestamp
- Post build task

## 2. System Setting (Manage Jenkins > System)
- Build Timestamp
  - Timezone: `Etc/GMT-9`
  - Pattern: `yyyyMMddHHmmss`
  
![](img/build-timestamp.png)


## 3. Tools Setting (Manage Jenkins > Tools)
- JDK
  - Name: Java17
  - Extract \*.zip/\*.tar.gz
    - Download URL for binary archive
      - arm64: `https://download.oracle.com/java/17/archive/jdk-17.0.7_linux-aarch64_bin.tar.gz`
      - amd64: `https://download.oracle.com/java/17/archive/jdk-17.0.7_linux-x64_bin.tar.gz`
    - Subdirectory of extracted archive: `jdk-17.0.7`

![](img/jdk.png)

- Gradle
  - name: `gradle 7.5.1`
  - Install from Gradle.org
    - Version: `Gradle 7.5.1`

![](img/gradle.png)

## 4. Create item 'member'

Freestyle project

![](img/item-jdk.png)

- Source Code Management
  - Repository URL: `https://github.com/gilbertlim/member-service.git`
  - Branch Specifier: `*/main`

![](img/source-code.png)

- Build Steps
  - Invoke Gradle script
    - Gradle Version: `gradle 7.5.1`
    - Tasks: `bootJar`

![](img/build-step.png)

  - Execute shell
    - Command
      ```sh
      echo $BUILD_TIMESTAMP
      tag=$BUILD_TIMESTAMP
      docker build -t member:$tag .
      docker tag member:$tag member:latest
      ```

![](img/execute-shell.png)

- Post-build Actions
  - Post build task
    - Script
      ```sh
      docker rm -f member
      docker run -d --name member -p 8080:8080 -e DB_CONNECTION_URL=jdbc:mysql://172.90.9.209:3306/member_service -e DB_USER=root -e DB_PASSWORD=password member:latest
      ```
    - 172.90.9.209: `ifconfig en0 | egrep -o 'inet ([0-9\.]*)' | awk '{print $2}'` 후 나오는 ip 사용
    - Run script only if all previous steps were successful

![](img/post-build-task.png)


## 5. Build

1. Dashboard > member > Build Now > #Build Number > Console Output
2. Check Result
- `docker exec -it jenkins-master-dind docker ps`