# AGENTS.md - AI Doctor OpenCode Development Guide

## Project Overview

This repository is a Docker-based development environment for running OpenCode (AI coding assistant) in a container. It does not contain application code but rather the infrastructure to run OpenCode as a web service.

- **Repository**: https://github.com/zylc369/ai-doctor-opencode
- **Container User**: `aiuser` (password: `Lcnihao2010`)
- **Working Directory**: `/home/aiuser/Codes`

---

## Build, Test & Development Commands

### Docker Commands

```bash
# Build the Docker image
docker-compose build

# Start the container (detached)
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down

# Restart with rebuild
docker-compose up -d --build

# Run a command inside the container
docker exec -it ai-doctor-opencode <command>
```

### Running Tests

This project does not contain application tests. The container runs:
- **OpenCode Web** on port 4096 (exposed as 4097)
- **Serve** (static file server) on port 4173

To verify the setup is working:
```bash
# Check container is running
docker ps | grep ai-doctor

# Test endpoints
curl http://localhost:4097
curl http://localhost:4173
```

### Development Workflow

1. Make changes to Docker config or volume-mounted files in `data/`
2. Rebuild/restart container: `docker-compose up -d --build`
3. Access OpenCode at `http://localhost:4097`

---

## Code Style Guidelines

### Dockerfile Conventions

- **Base Image**: Use Ubuntu 22.04 (`ubuntu:22.04`)
- **Non-interactive**: Always set `ENV DEBIAN_FRONTEND=noninteractive`
- **Cleanup**: Remove apt lists after installs (`rm -rf /var/lib/apt/lists/*`)
- **Layer Ordering**: Put rarely-changing layers first (base packages), frequently-changing last (code)
- **User Setup**: Create non-root user for running services
- **Expose Ports**: Document all exposed ports with comments

```dockerfile
# Example pattern
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash aiuser
WORKDIR /home/aiuser

EXPOSE 4096 4173
USER aiuser
```

### docker-compose.yml Conventions

- **Port Mapping**: Use format `"host:container"`
- **Volume Mounts**: Use relative paths for local dev
- **Restart Policy**: Use `restart: on-failure:5` for services
- **Command**: Use heredoc format for complex commands

```yaml
services:
  service-name:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ai-doctor-opencode
    ports:
      - "4097:4096"
    volumes:
      - ./data/notes:/home/aiuser/Codes/ai-doctor-opencode/notes
    restart: on-failure:5
    command: >
      bash -c "echo 'Starting...' && run-server"
```

### Shell Scripting (in container)

- Use `bash -c "..."` for multi-command scripts
- Use `&&` for dependent commands, `;` for independent
- Always redirect stderr where appropriate

---

## TypeScript/JavaScript Guidelines

If adding Node.js scripts to this project:

- **Import Style**: Use ES modules (`import { foo } from './module'`)
- **No Type Suppression**: Never use `as any`, `@ts-ignore`, `@ts-expect-error`
- **Error Handling**: Always use try/catch with proper error propagation
- **Naming**: camelCase for variables/functions, PascalCase for components/classes

---

## Git Conventions

- **Commit Messages**: Chinese or English, concise (under 50 chars for subject)
- **Branch Strategy**: Main branch for production
- **No Force Push**: Never force push to main

---

## Volume-Mounted Paths

The following directories are mounted from host to container:

| Host Path | Container Path | Purpose |
|-----------|----------------|---------|
| `./data/notes` | `/home/aiuser/Codes/ai-doctor-opencode/notes` | Notes directory |
| `./data/home/.cache/opencode` | `/home/aiuser/.cache/opencode` | OpenCode cache |
| `./data/home/.config/opencode` | `/home/aiuser/.config/opencode` | OpenCode config |
| `./data/home/.local/share/opencode` | `/home/aiuser/.local/share/opencode` | OpenCode data |
| `./data/home/.local/state/opencode` | `/home/aiuser/.local/state/opencode` | OpenCode state |

---

## Common Tasks

### Update OpenCode Version
Edit the version in `Dockerfile`:
```dockerfile
# Line ~62: Download URL
RUN cd /tmp && \
    curl -fsSL https://github.com/zylc369/opencode/releases/download/vX.X.X.X/opencode-linux-arm64.tar.gz
```

### Add New Dependency
1. Add install command in `Dockerfile` (before the USER line)
2. If binary: Ensure it's in PATH or reference full path
3. Rebuild: `docker-compose up -d --build`

### Debug Container Issues
```bash
# Enter container shell
docker exec -it ai-doctor-opencode /bin/bash

# Check running processes
docker exec ai-doctor-opencode ps aux

# Check logs
docker-compose logs opencode
```

---

## Notes

- This is an infrastructure project - no traditional "lint/test" commands apply
- All code execution happens inside the Docker container
- The cloned repo (`ai-doctor-opencode`) inside container may contain actual project code - check `/home/aiuser/Codes/ai-doctor-opencode` for that code's AGENTS.md
