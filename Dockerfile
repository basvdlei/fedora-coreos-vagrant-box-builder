FROM registry.fedoraproject.org/fedora:30
RUN dnf install -y coreutils curl gzip jq make 
COPY . /build/
WORKDIR /build
ENV OUTPUT_DIR /output
CMD [ "/usr/bin/make" ]
