FROM fedora:latest

RUN dnf install -y \
    vim \
    less \
    nushell \
    curl \
    ca-certificates \
    && dnf clean all

RUN curl -fsSL https://dl.k8s.io/release/v1.29.0/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

RUN kubectl version --client

WORKDIR /workspace

CMD ["/bin/bash"]
