FROM openjdk:8-jdk-alpine AS builder

RUN apk add curl tar git bash

WORKDIR /opt

RUN curl -LO https://piccolo.link/sbt-1.2.3.tgz \
  && tar -xzf sbt*.tgz \
  && rm sbt*.tgz

ENV PATH=$PATH:/opt/sbt/bin

RUN git clone https://github.com/broadinstitute/cromwell.git

WORKDIR cromwell

RUN apk add zip gzip
RUN sbt assembly

FROM openjdk:8-jre-alpine AS final
RUN apk add bash
WORKDIR /opt/cromwell
COPY --from=builder /opt/cromwell/server/target/scala-2.12/cromwell*.jar .

RUN ln -s $(find . | grep 'cromwell.*\.jar') /opt/cromwell/cromwell.jar

ADD ./cromwell.sh /opt/cromwell/
RUN chmod +x /opt/cromwell/cromwell.sh

ENTRYPOINT ["/opt/cromwell/cromwell.sh"]
CMD ["server"]
