# Dockerfile
FROM python:3.9-slim-buster

WORKDIR /usr/app

# Install Linux Packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    wget \
    snapd \
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
    alien && \
    apt-get purge -y --auto-remove

# Install Python packages
COPY requirements.txt ./
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Install snowflake-snowsql
RUN curl "https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/1.2/linux_x86_64/snowflake-snowsql-1.2.10-1.x86_64.rpm" -o /tmp/snowflake-snowsql.rpm
RUN alien -i /tmp/snowflake-snowsql.rpm

# Install teraform
RUN wget -qO - terraform.gpg https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/terraform-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/terraform-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/terraform.list
RUN apt update
RUN apt install terraform
