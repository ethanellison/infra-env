FROM fedora:latest

RUN dnf install -y \
    kubectl \
    helm \
    kustomize \
    jq \
    yq \
    git \
    nushell \
    bash-completion \
    iproute \
    iputils \
    bind-utils \
    net-tools \
    openssh-clients \
    curl \
    wget \
    vim \
    tmux \
    htop \
    && dnf clean all

RUN echo "source <(kubectl completion bash)" >> /etc/bashrc

WORKDIR /workspace

CMD ["/bin/bash"]
