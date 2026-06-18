# Dockerfile
FROM python:3.11-slim-bookworm

WORKDIR /usr/app

ENV DEBIAN_FRONTEND=noninteractive

# Install Linux Packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    wget \
    git \
    curl \
    sshpass \
    openssh-server \
    sudo \
    nmap \
    gnupg \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    alien \
    jq \
    nano && \
    rm -rf /var/lib/apt/lists/*

# Install Python packages
COPY requirements.txt ./
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Install snowflake-snowsql (Debian via alien from RPM)
RUN curl -fsSL "https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/1.3/linux_x86_64/snowflake-snowsql-1.3.2-1.x86_64.rpm" -o /tmp/snowflake-snowsql.rpm && \
    alien -i /tmp/snowflake-snowsql.rpm && \
    rm /tmp/snowflake-snowsql.rpm

# Install Snowflake CLI (snow) — pinned for DCM Projects support
RUN pip install --no-cache-dir "snowflake-cli>=3.16.0"

# Install Cortex Code CLI (best-effort)
RUN curl -LsS https://ai.snowflake.com/static/cc-scripts/install.sh | sh || true

# Install terraform
RUN wget -qO - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/terraform-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/terraform-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/terraform.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends terraform && \
    rm -rf /var/lib/apt/lists/*
