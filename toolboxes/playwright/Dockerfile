FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g playwright && \
    playwright install --with-deps chromium firefox webkit

WORKDIR /workspace

CMD ["/bin/bash"]
