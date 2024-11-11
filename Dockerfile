# Use the latest Debian slim version as base image
FROM debian:stable-slim

# Set environment variables for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive

# Declare build arguments for PUID, PGID, Hugo URL, and default SSH password
ARG PUID=1000
ARG PGID=1000
ARG HUGO_URL=https://github.com/gohugoio/hugo/releases/download/v0.89.4/hugo_extended_0.89.4_Linux-64bit.deb
ARG ABC_PASSWORD=changeme

# Install necessary packages: wget, sudo, and openssh-server
RUN apt-get update && \
    apt-get install -y \
    wget \
    sudo \
    nano \
    openssh-server \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create user and group for "abc" using PUID and PGID from build arguments
RUN groupadd -g ${PGID} abc && \
    useradd -u ${PUID} -g abc -m -d /home/abc abc && \
    echo "abc:${ABC_PASSWORD}" | chpasswd

# Create necessary directories and ensure permissions
RUN mkdir -p /home/abc /var/run/sshd && \
    chown -R abc:abc /home/abc

# Ensure passwordless sudo for "abc"
RUN usermod -aG sudo abc && \
    echo 'abc ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Configure SSH server
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'AllowUsers abc' >> /etc/ssh/sshd_config

# Expose port 22 (for SSH)
EXPOSE 22

# Install Hugo using the provided HUGO_URL argument
RUN wget -O /tmp/hugo.deb ${HUGO_URL} && \
    dpkg -i /tmp/hugo.deb && \
    rm /tmp/hugo.deb

# Set working directory to abc's home
WORKDIR /home/abc

# Switch to non-root user (abc)
USER abc

# Generate SSH host keys at runtime and start SSH daemon
CMD ["/bin/bash", "-c", "if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then sudo ssh-keygen -A; fi && sudo /usr/sbin/sshd -D"]
