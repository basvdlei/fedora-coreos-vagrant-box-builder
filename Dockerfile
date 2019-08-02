FROM registry.fedoraproject.org/fedora:30
RUN dnf install -y coreutils curl gzip jq make 
COPY ignition.json info-template.json Makefile metadata.json Vagrantfile /build/
WORKDIR /build
ENV OUTPUT_DIR /output
CMD [ "/usr/bin/make" ]
