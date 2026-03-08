#!/bin/bash
set -e

# Configure Git to use GitHub Token for authentication
if [ -n "$GITHUB_TOKEN" ]; then
    echo "Configuring Git to use GitHub Token..."
    
    # Configure git credential helper
    git config --global credential.helper store
    
    # Store credentials for github.com
    # This will be used ONLY when Git needs authentication (private repos or push operations)
    echo "https://${GITHUB_TOKEN}@github.com" > ~/.git-credentials
    chmod 600 ~/.git-credentials
    
    # NOTE: We do NOT configure URL rewrite here because:
    # 1. Public repos don't need authentication - they work without token
    # 2. Token with limited scope would cause 403 errors for other repos
    # 3. Git will automatically use credentials from .git-credentials when needed
    
    echo "Git configured successfully."
    echo "- Public repos: clone without authentication"
    echo "- Private repos with token access: will use token automatically"
    echo "- Private repos without token access: will fail (expected)"
else
    echo "Warning: GITHUB_TOKEN not set. Git operations may fail for private repos."
fi

# Clone or pull buwai-ai-extension repository
# Use GITHUB_TOKEN in URL for private repo support
if [ -n "$GITHUB_TOKEN" ]; then
    REPO_URL="https://${GITHUB_TOKEN}@github.com/zylc369/buwai-ai-extension"
else
    REPO_URL="https://github.com/zylc369/buwai-ai-extension"
fi
REPO_DIR="/home/aiuser/Codes/buwai-ai-extension"
BRANCH="main"

echo ""
echo "Setting up buwai-ai-extension repository..."

if [ -d "$REPO_DIR/.git" ]; then
    echo "Repository exists, pulling latest changes..."
    cd "$REPO_DIR"
    git fetch origin "$BRANCH"
    git reset --hard "origin/$BRANCH"
    echo "Repository updated to latest $BRANCH branch."
else
    echo "Cloning repository..."
    # Clear directory contents (can't remove mount point itself)
    rm -rf "${REPO_DIR:?}/"* "${REPO_DIR:?}/."* 2>/dev/null || true
    git clone --branch "$BRANCH" --single-branch "$REPO_URL" "$REPO_DIR"
    echo "Repository cloned successfully."
fi

# Replace remote URL to remove token (credential.helper will handle auth)
if [ -d "$REPO_DIR/.git" ]; then
    cd "$REPO_DIR"
    git remote set-url origin "https://github.com/zylc369/buwai-ai-extension"
    
    # Install AI extensions
    echo "Installing AI extensions..."
    chmod +x install-ai-extensions.sh
    ./install-ai-extensions.sh
fi

# Execute the passed command
exec "$@"
