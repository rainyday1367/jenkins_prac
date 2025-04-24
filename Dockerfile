## 가독성을 올리기 위한, 설명 주석
# 코드 주석

## build된 jar 파일이 있는 경우

#FROM eclipse-temurin:17-jre
#WORKDIR /app
#COPY build/libs/*.jar ./
#RUN mv $(ls *.jar | grep -v plain) app.jar
#ENTRYPOINT ["java", "-jar", "app.jar"]

## 2. build 후 jar 파일로 실행되게 수정(멀티 스테이징), jdk 버전 잘 따져야함
## 2-1. gradle image로 build(jar 생성), gradle 명령어를 쓸 수 있게 gradle를 통해 build 명령어 사용
FROM gradle:8.5-jdk17 AS build
WORKDIR /app
## app라는 폴더에 프로젝트를 통째로 복사?, jar파일이 없다는 가정
COPY . .

## daemon 스레드를 쓰지 않음으로써 쓸데없이 리소스가 소모되는 것을 방지하는 코드로 작성
RUN #gradle clean build --no-daemon
RUN gradle clean build --no-daemon -x test

## 2-2. 앞선 build라는 이름의 스테이지 결과로 실행 스테이지 시작
## jre를 통해 java 명령어 컨테이너가 실행할 명령어 뭔지 명시?
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar ./
RUN mv $(ls *.jar | grep -v plain) app.jar

## 컨테이너 내부에서는 7777포트로 app.jar가 실행됨
ENTRYPOINT ["java", "-jar", "app.jar"]