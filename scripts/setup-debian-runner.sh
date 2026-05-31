#!/usr/bin/env bash
# Setup script for a GitHub Actions self-hosted runner on Debian trixie.
# Run as root (or with sudo) on a Debian trixie machine.
#
# Usage:
#   sudo bash setup-debian-runner.sh <REGISTRATION_TOKEN> [RUNNER_NAME]
#
# Get a fresh token at:
#   gh api repos/BenJule/BambuStudio/actions/runners/registration-token -X POST --jq '.token'
set -euo pipefail

REPO_URL="https://github.com/BenJule/BambuStudio"
RUNNER_VERSION="2.334.0"
RUNNER_USER="github-runner"
RUNNER_DIR="/opt/github-runner-debian"
CCACHE_DIR="/var/cache/github-runner-debian/ccache"
DEPS_CACHE_DIR="/var/cache/github-runner-debian/deps"

TOKEN="${1:-}"
RUNNER_NAME="${2:-debian-trixie-$(hostname -s)}"

if [[ -z "$TOKEN" ]]; then
  echo "Usage: $0 <REGISTRATION_TOKEN> [RUNNER_NAME]" >&2
  exit 1
fi

echo "=== Installing build dependencies ==="
apt-get update -qq
apt-get install -y --no-install-recommends \
  sudo git git-lfs curl wget tar libicu-dev \
  build-essential cmake ninja-build pkg-config \
  ccache \
  libssl-dev libcurl4-openssl-dev \
  libgtk-3-dev libglib2.0-dev libsecret-1-dev \
  libwebkit2gtk-4.1-dev \
  jq

echo "=== Creating runner user ==="
if ! id "$RUNNER_USER" &>/dev/null; then
  useradd -m -s /bin/bash "$RUNNER_USER"
fi

echo "=== Creating directories ==="
mkdir -p "$RUNNER_DIR" "$CCACHE_DIR" "$DEPS_CACHE_DIR"
chown -R "$RUNNER_USER:$RUNNER_USER" "$RUNNER_DIR" "$CCACHE_DIR" "$DEPS_CACHE_DIR"

echo "=== Downloading runner v${RUNNER_VERSION} ==="
RUNNER_ARCHIVE="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
curl -fsSL \
  "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${RUNNER_ARCHIVE}" \
  -o "/tmp/${RUNNER_ARCHIVE}"
tar -xzf "/tmp/${RUNNER_ARCHIVE}" -C "$RUNNER_DIR"
chown -R "$RUNNER_USER:$RUNNER_USER" "$RUNNER_DIR"

echo "=== Configuring runner ==="
sudo -u "$RUNNER_USER" "$RUNNER_DIR/config.sh" \
  --unattended \
  --url "$REPO_URL" \
  --token "$TOKEN" \
  --name "$RUNNER_NAME" \
  --labels "self-hosted,debian-trixie,linux,x64" \
  --work "$RUNNER_DIR/_work" \
  --replace

echo "=== Installing systemd service ==="
"$RUNNER_DIR/svc.sh" install "$RUNNER_USER"

echo "=== Configuring ccache for runner user ==="
sudo -u "$RUNNER_USER" bash -c "
  git config --global --add safe.directory '*'
  mkdir -p ~/.config/ccache
  cat > ~/.config/ccache/ccache.conf <<'CCCONF'
max_size = 10G
cache_dir = ${CCACHE_DIR}
compression = true
CCCONF
"

echo "=== Adding runner to sudoers (for apt-get in build scripts) ==="
cat > /etc/sudoers.d/github-runner <<'SUDO'
github-runner ALL=(ALL) NOPASSWD: /usr/bin/apt-get
SUDO
chmod 0440 /etc/sudoers.d/github-runner

echo "=== Starting service ==="
systemctl start "actions.runner.$(echo "${REPO_URL##*/github.com/}" | tr '/' '.').${RUNNER_NAME}.service" || \
  "$RUNNER_DIR/svc.sh" start

echo ""
echo "=== Runner setup complete ==="
echo "Name:    $RUNNER_NAME"
echo "Labels:  self-hosted,debian-trixie,linux,x64"
echo "ccache:  $CCACHE_DIR"
echo "deps:    $DEPS_CACHE_DIR"
echo ""
echo "Check status: systemctl status 'actions.runner.*${RUNNER_NAME}*'"
echo "Verify at:    https://github.com/BenJule/BambuStudio/settings/actions/runners"
