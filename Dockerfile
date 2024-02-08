FROM ubuntu:latest
ADD https://s3.us-west-2.amazonaws.com/amazon-eks/1.23.15/2023-01-11/bin/linux/amd64/kubectl .
RUN chmod +x ./kubectl && mv ./kubectl /usr/local/bin

RUN apt-get update && apt install jq -y && apt install bc -y
COPY BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/
COPY build.sh .
COPY config .

USER root
RUN chmod +x build.sh

ENV ACTIVITY_SUB_TASK_CODE BP-ENV-COMPARATOR
ENV VALIDATION_FAILURE_ACTION WARNING
ENV SLEEP_DURATION 5s

ENV SERVICE_NAME xyz
ENV CM_NAMESPACES xyz
ENV SOURCE_NAMESPACE xyz

ENTRYPOINT ["./build.sh" ]
