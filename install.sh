#!/bin/bash
# ╔══════════════════════════════════════════╗
# ║          AI on Pi – Installer            ║
# ╚══════════════════════════════════════════╝

set -e

# ── Farben & Symbole ────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

TOTAL_STEPS=7
CURRENT_STEP=0

# ── Hilfsfunktionen ─────────────────────────────────────────────────────────

step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  echo -e "\n${BOLD}${GREEN}[$CURRENT_STEP/$TOTAL_STEPS]${NC} ${BOLD}$1${NC}"
}

ok()    { echo -e "  ${GREEN}✓${NC} $1"; }
warn()  { echo -e "  ${YELLOW}⚠${NC} $1"; }
error() { echo -e "\n  ${RED}✗ Fehler: $1${NC}\n"; exit 1; }
info()  { echo -e "  ${DIM}→ $1${NC}"; }

# Spinner für stumme Befehle
spinner() {
  local pid=$1
  local label=$2
  local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local i=0
  tput civis 2>/dev/null
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${CYAN}${spin[$i]}${NC}  ${DIM}%s${NC}" "$label"
    i=$(( (i+1) % 10 ))
    sleep 0.1
  done
  printf "\r%-60s\r" " "
  tput cnorm 2>/dev/null
}

# Fortschrittsbalken zeichnen
draw_bar() {
  local pct=$1
  local label=$2
  local width=30
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty;  i++)); do bar+="░"; done
  printf "\r  ${CYAN}[%s]${NC} %3d%%  ${DIM}%s${NC}          " "$bar" "$pct" "$label"
}

# Ollama-Pull mit Live-Fortschrittsbalken
pull_with_progress() {
  local model=$1

  ollama pull "$model" 2>&1 | while IFS= read -r line; do
    if [[ "$line" =~ ([0-9]+)%.*([0-9]+(\.[0-9]+)?\ [KMGT]?B/[0-9]+(\.[0-9]+)?\ [KMGT]?B) ]]; then
      local pct="${BASH_REMATCH[1]}"
      local size="${BASH_REMATCH[2]}"
      draw_bar "$pct" "$size"
    elif [[ "$line" =~ pulling\ manifest ]]; then
      printf "\r  ${DIM}→ Manifest laden...${NC}                              "
    elif [[ "$line" =~ verifying ]]; then
      printf "\r  ${DIM}→ SHA256 prüfen...${NC}                               "
    elif [[ "$line" =~ writing\ manifest ]]; then
      printf "\r  ${DIM}→ Manifest schreiben...${NC}                          "
    elif [[ "$line" =~ success ]]; then
      printf "\r%-60s\r" " "
    fi
  done

  echo ""
}

# ── Banner ───────────────────────────────────────────────────────────────────
clear
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║          AI on Pi – Installer            ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Schritte: ${DIM}System → Node.js → npm → Ollama → Dienst → Modell → Autostart${NC}"
echo ""

# ── 1. System aktualisieren ─────────────────────────────────────────────────
step "System aktualisieren"
(sudo apt-get update -qq && sudo apt-get upgrade -y -qq) &
spinner $! "apt update & upgrade läuft..."
ok "System aktuell"

# ── 2. Node.js ──────────────────────────────────────────────────────────────
step "Node.js prüfen"
if command -v node &>/dev/null; then
  ok "Node.js bereits installiert ($(node -v))"
else
  info "Wird installiert (Node.js 20 LTS)..."
  (curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &>/dev/null &&
   sudo apt-get install -y nodejs &>/dev/null) &
  spinner $! "Node.js wird heruntergeladen..."
  ok "Node.js $(node -v) installiert"
fi

# ── 3. npm-Pakete ────────────────────────────────────────────────────────────
step "npm-Pakete installieren"
[ ! -f "package.json" ] && error "package.json nicht gefunden! Skript im Projektordner ausführen."
(npm install --silent) &
spinner $! "npm install läuft..."
ok "Alle Pakete installiert"

# ── 4. Ollama installieren ───────────────────────────────────────────────────
step "Ollama prüfen"
if command -v ollama &>/dev/null; then
  ok "Ollama bereits installiert ($(ollama --version 2>/dev/null || echo 'ok'))"
else
  info "Ollama wird heruntergeladen..."
  (curl -fsSL https://ollama.com/install.sh | sh &>/dev/null) &
  spinner $! "Ollama Installer läuft..."
  ok "Ollama installiert"
fi

# ── 5. Ollama-Dienst starten ─────────────────────────────────────────────────
step "Ollama-Dienst starten"
if systemctl is-active --quiet ollama 2>/dev/null; then
  ok "Ollama läuft bereits"
else
  sudo systemctl enable ollama &>/dev/null || true
  sudo systemctl start ollama  &>/dev/null || (ollama serve &>/dev/null &)
  sleep 3
  ok "Ollama gestartet"
fi

# ── 6. phi3-Modell laden ─────────────────────────────────────────────────────
step "phi3-Modell herunterladen"
if ollama list 2>/dev/null | grep -q "phi3"; then
  ok "phi3 bereits vorhanden"
else
  info "Download startet – das kann je nach Verbindung 5–15 Min. dauern (~2.3 GB)"
  echo ""
  pull_with_progress "phi3"
  ok "phi3 erfolgreich geladen"
fi

# ── 7. Autostart einrichten ──────────────────────────────────────────────────
step "Autostart einrichten"
echo ""
read -rp "  Soll der Server beim Systemstart automatisch starten? (j/n): " AUTOSTART

if [[ "$AUTOSTART" =~ ^[jJyY]$ ]]; then
  PROJECT_DIR=$(pwd)
  NODE_PATH=$(which node)

  sudo tee /etc/systemd/system/local-ai.service > /dev/null <<EOF
[Unit]
Description=Local AI Chat Server
After=network.target ollama.service
Requires=ollama.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$PROJECT_DIR
ExecStart=$NODE_PATH $PROJECT_DIR/server.js
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable local-ai &>/dev/null
  sudo systemctl start  local-ai
  ok "Autostart aktiviert (Dienst: local-ai)"
else
  info "Autostart übersprungen"
fi

# ── Fertig ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║       ✓  Installation abgeschlossen!     ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}Starten:${NC}   npm start"
echo -e "  ${BOLD}Öffnen:${NC}    ${CYAN}http://$(hostname -I | awk '{print $1}'):3000${NC}"
echo ""