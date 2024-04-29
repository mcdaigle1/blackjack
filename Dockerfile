FROM eclipse-temurin:17-jdk-focal
COPY target/kube_demo-0.0.1-SNAPSHOT.jar kube_demo.jar
ENTRYPOINT ["java","-jar","/kube_demo.jar"]