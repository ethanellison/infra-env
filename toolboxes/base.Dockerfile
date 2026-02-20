FROM fedora:latest

RUN dnf install -y \
    # rust-nu \
    jq \
    yq \
    git \
    bash-completion \
    openssh-clients \
    curl \
    wget \
    neovim \
    tmux \
    htop \
    podman-remote \
    && dnf clean all

RUN dnf install -y dnf-plugins-core \
  && dnf copr enable jdxcode/mise -y \
  && dnf install -y mise \
  && dnf clean all

WORKDIR /workspace

CMD ["/bin/bash"]
