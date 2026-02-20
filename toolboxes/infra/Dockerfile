FROM localhost/toolbox-base:latest

RUN dnf install -y \
    # rust-nu \
    kubernetes-client \
    helm \
    kustomize \
    iproute \
    iputils \
    bind-utils \
    net-tools \
    && dnf clean all

RUN echo "source <(kubectl completion bash)" >> /etc/bashrc

WORKDIR /workspace

CMD ["/bin/bash"]
