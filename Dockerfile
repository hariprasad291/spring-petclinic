FROM openjdk:11
LABEL author 'hari'
ENV SPC_VERSION=2.7.3
EXPOSE 8080
RUN useradd -m kubernetes
USER kubernetes
WORKDIR /home/kubernetes/
COPY --chown=kubernetes spring-petclinic-$SPC_VERSION.jar /home/kubernetes/spring-petclinic-$SPC_VERSION.jar
CMD ["java", "-jar", "/home/kubernetes/spring-petclinic-$SPC_VERSION.jar"]