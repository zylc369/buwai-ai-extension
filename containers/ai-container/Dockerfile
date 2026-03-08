FROM ubuntu:22.04

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    sudo \
    unzip \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (NodeSource) for serve package
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install serve globally
RUN npm install -g serve

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Install OpenCode (will be replaced later)
# RUN curl -fsSL https://opencode.ai/install | bash
RUN curl -fsSL https://raw.githubusercontent.com/zylc369/opencode/refs/heads/feature/optimization_v1_1/install-zylc369 | bash

# Create user 'aiuser' with password (for sudo access)
RUN useradd -m -s /bin/bash aiuser && \
    echo "aiuser:Lcnihao2010" | chpasswd && \
    echo "aiuser ALL=(ALL) ALL" >> /etc/sudoers

# Copy opencode and bun to aiuser's home
RUN mkdir -p /home/aiuser/.opencode && \
    cp -r /root/.opencode/* /home/aiuser/.opencode/ && \
    mkdir -p /home/aiuser/.bun && \
    (cp -r /root/.bun/* /home/aiuser/.bun/ 2>/dev/null || true)

# Copy opencode config
RUN mkdir -p /home/aiuser/.config/opencode

# Switch to user directory
WORKDIR /home/aiuser

# Create Codes directory
RUN mkdir -p /home/aiuser/Codes

# Clone ai-doctor-opencode repository to ~/Codes/ai-doctor-opencode
RUN git clone https://github.com/zylc369/ai-doctor-opencode.git /home/aiuser/Codes/ai-doctor-opencode

# Create notes directory
RUN mkdir -p /home/aiuser/Codes/ai-doctor-opencode/notes

# Install oh-my-opencode (with OpenCode Zen for free models)
RUN cd /home/aiuser && \
    /home/aiuser/.bun/bin/bunx oh-my-opencode install --no-tui --claude=no --openai=no --gemini=no --copilot=no --opencode-zen=yes

# Configure ll command as global executable
RUN printf '#!/bin/sh\nexec ls -ahl "$@"' > /usr/local/bin/ll && chmod +x /usr/local/bin/ll
# Ensure proper ownership
RUN chown -R aiuser:aiuser /home/aiuser

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set PATH environment variable for runtime
ENV PATH="/home/aiuser/.opencode/bin:/home/aiuser/.bun/bin:$PATH"

# Switch to non-root user
USER aiuser

# Use entrypoint to configure Git with GitHub Token
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Expose ports (4096 for opencode web, 4173 for serve)
EXPOSE 4096 4173
