FROM fedora:latest

RUN dnf install -y \
    python3 \
    python3-pip \
    python3-venv \
    golang \
    nodejs \
    npm \
    git \
    nushell \
    curl \
    wget \
    vim \
    nano \
    tmux \
    htop \
    ca-certificates \
    build-essential \
    && dnf clean all

WORKDIR /workspace

CMD ["/bin/bash"]
