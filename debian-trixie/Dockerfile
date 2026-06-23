FROM debian:trixie-slim

LABEL Name="do-agent"
LABEL Version="4.274.1.3"

LABEL org.opencontainers.image.title="do-agent"
LABEL org.opencontainers.image.version="trixie-4.274.1.3"
LABEL org.opencontainers.doa.version="linux-amd64-4.274.1"

# Prevent interactive prompts during package installation (e.g., timezone selection)
ENV DEBIAN_FRONTEND=noninteractive

# Update repository lists and install native dependencies required by the agent and Git
RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
    ca-certificates \
    curl \
    git \
    libicu76 \
    libcurl4t64 \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the working directory inside the container
WORKDIR /DOA

# Copy the runtime bootstrap script from the host to the container
COPY start.sh .

# Grant execution permissions to the script
RUN chmod +x start.sh

# Define the script as the main entry point when the container boots up
ENTRYPOINT ["./start.sh"]

# Empty CMD instruction to silence the linter
CMD []
