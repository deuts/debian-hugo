# Hugo with SSH in Docker

This repository provides a Dockerized setup for running [Hugo](https://gohugo.io/) with SSH access, built on Debian Slim. The container allows remote access via SSH, making it easier to manage Hugo projects.

## Features

- **Hugo**: Easily build and serve static sites using Hugo.
- **SSH Access**: Connect remotely to the container for project management.
- **Custom User Configuration**: Configure user and group ID to match your host system.
- **Passwordless sudo** for the main user for seamless command execution.

## Getting Started

### Prerequisites

- [Docker](https://www.docker.com/) installed on your system.
- (Optional) [Docker Compose](https://docs.docker.com/compose/) for using `compose.yml`.

### Setup

1. **Clone this repository**:
   ```bash
   git clone https://github.com/yourusername/yourrepositoryname.git
   cd yourrepositoryname
   ```

2. **Modify Environment Variables** (Optional):
   - In the `compose.yml` file, adjust `PUID`, `PGID`, and `ABC_PASSWORD` as needed.
     - `PUID` and `PGID` should match your host system's user and group IDs.
     - `ABC_PASSWORD` is the SSH password for the `abc` user.

3. **Build and Run the Docker Container**:
   - With Docker Compose:
     ```bash
     docker compose up -d
     ```
   - Or, manually build and run:
     ```bash
     docker build -t hugoapp .
     docker run -d -p 2223:22 --name hugo hugoapp
     ```

   > **Note**: SSH will be accessible on your host at port `2223`.

4. **Set Ownership of `/home/abc` Inside the Running Container**:
   - After the container is up, ensure `/home/abc` is owned by the `abc` user by executing the following command:
     ```bash
     docker exec -it hugo chown -R abc:abc /home/abc
     ```

5. **Access the Container via SSH**:
   - Use the SSH password you set in `compose.yml` (`ABC_PASSWORD`).
   ```bash
   ssh abc@localhost -p 2223
   ```

### Folder Structure

- `/sites`: Maps to `/home/abc` in the container for easy access to your Hugo site files.

### Updating Hugo Version

- To update Hugo, change the `HUGO_URL` argument in `compose.yml` to the desired version URL.

## Dockerfile Details

The Dockerfile does the following:

1. Installs dependencies: `wget`, `sudo`, `openssh-server`.
2. Sets up a non-root user (`abc`) with sudo privileges and SSH access.
3. Installs Hugo based on the URL specified in the `HUGO_URL` build argument.
4. Exposes SSH on port 22, mapped to host port `2223` in `compose.yml`.
5. Automatically generates SSH keys at runtime.

## Environment Variables and Build Arguments

| Argument         | Description                                                                                             |
|------------------|---------------------------------------------------------------------------------------------------------|
| `PUID`           | User ID for the `abc` user, defaults to `1000`. Adjust to your host's UID to avoid permission issues.  |
| `PGID`           | Group ID for the `abc` user, defaults to `1000`. Adjust to your host's GID to avoid permission issues.  |
| `HUGO_URL`       | URL to the Hugo release `.deb` file. Defaults to `v0.89.4`.                                            |
| `ABC_PASSWORD`   | Default password for SSH access to `abc`.                                                               |

## License

This project is licensed under the MIT License.
