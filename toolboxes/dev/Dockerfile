FROM localhost/toolbox-base:latest

RUN dnf install -y \
    python3 \
    python3-pip \
    uv \
    golang \
    nodejs \
    npm \
    yarn \
    && dnf clean all

WORKDIR /workspace

CMD ["/bin/bash"]
