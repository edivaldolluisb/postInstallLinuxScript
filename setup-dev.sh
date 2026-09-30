#!/usr/bin/env bash
# setup-dev.sh - Setup dev para Zorin OS 18 (Ubuntu 24.04) | tudo via apt
set -euo pipefail

command -v dialog >/dev/null || { sudo apt update && sudo apt install -y dialog; }
sudo -v; while true; do sudo -n true; sleep 60; done & TRAP_PID=$!
trap "kill $TRAP_PID 2>/dev/null" EXIT

CHOICES=$(dialog --title "Dev Setup - Zorin OS" --checklist \
  "Selecione o que instalar:" 20 60 10 \
  git       "Git + config basica"            ON \
  python    "Python 3.12 + pip + venv"       ON \
  node      "Node.js 22 LTS (NodeSource)"    ON \
  java      "OpenJDK 21 (LTS)"               ON \
  docker    "Docker Engine (docker.io)"      ON \
  vscode    "VS Code (repo Microsoft)"       ON \
  extras    "build-essential, curl, jq, unzip" ON \
  3>&1 1>&2 2>&3)

ok() { echo -e "\n\033[1;32m==> $1\033[0m"; }
sudo apt update -y

for c in $CHOICES; do
  case "$c" in
    git)
      ok "Git"
      sudo apt install -y git
      ;;
    python)
      ok "Python"
      sudo apt install -y python3 python3-pip python3-venv python3-dev
      ;;
    node)
      ok "Node.js 22 LTS (NodeSource)"
      curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
      sudo apt install -y nodejs
      ;;
    java)
      ok "OpenJDK 21"
      sudo apt install -y openjdk-21-jdk
      ;;
    docker)
      ok "Docker Engine"
      sudo apt install -y docker.io docker-compose-v2
      sudo systemctl enable --now docker
      sudo usermod -aG docker "$USER"   # relog p/ usar sem sudo
      ;;
    vscode)
      ok "VS Code"
      wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg >/dev/null
      echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
      sudo apt update -y && sudo apt install -y code
      ;;
    extras)
      ok "Extras"
      sudo apt install -y build-essential curl wget jq unzip zip gnupg ca-certificates
      ;;
  esac
done

ok "Verificacao"
for t in git python3 node npm java docker code; do
  command -v $t >/dev/null && printf "  %-9s %s\n" "$t" "$($t --version 2>&1 | head -1)" || echo "  $t  (nao instalado)"
done
echo -e "\nFeito. Faca logout/login se marcou Docker."
