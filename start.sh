#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# ToolXr — Quick Start Script
# Run this from the project root: bash start.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}${CYAN}  ████████╗ ██████╗  ██████╗ ██╗     ██╗  ██╗██████╗  ${NC}"
echo -e "${BOLD}${CYAN}     ██╔══╝██╔═══██╗██╔═══██╗██║     ╚██╗██╔╝██╔══██╗ ${NC}"
echo -e "${BOLD}${CYAN}     ██║   ██║   ██║██║   ██║██║      ╚███╔╝ ██████╔╝ ${NC}"
echo -e "${BOLD}${CYAN}     ██║   ██║   ██║██║   ██║██║      ██╔██╗ ██╔══██╗ ${NC}"
echo -e "${BOLD}${CYAN}     ██║   ╚██████╔╝╚██████╔╝███████╗██╔╝ ██╗██║  ██║ ${NC}"
echo -e "${BOLD}${CYAN}     ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ${NC}"
echo ""
echo -e "${CYAN}  38 Tools · PDF · Image · Code · Convert${NC}"
echo ""
echo -e "────────────────────────────────────────────────────────"

# ── Check Node.js ─────────────────────────────────────────────────────────────
if ! command -v node &> /dev/null; then
  echo -e "${RED}✗ Node.js not found.${NC}"
  echo -e "  Install from: ${CYAN}https://nodejs.org${NC}  (LTS version)"
  echo -e "  Linux: curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash - && sudo apt install -y nodejs"
  exit 1
fi
NODE_VER=$(node --version)
echo -e "${GREEN}✓ Node.js ${NODE_VER}${NC}"

# ── Install backend dependencies if missing ────────────────────────────────────
if [ ! -d "backend/node_modules" ]; then
  echo -e "${YELLOW}⏳ Installing backend dependencies...${NC}"
  cd backend && npm install && cd ..
  echo -e "${GREEN}✓ Dependencies installed${NC}"
else
  echo -e "${GREEN}✓ Dependencies already installed${NC}"
fi

# ── Check optional system tools ───────────────────────────────────────────────
echo ""
echo -e "${BOLD}System tools check:${NC}"

if command -v libreoffice &> /dev/null; then
  echo -e "${GREEN}✓ LibreOffice found  — Word/Excel/PPT conversion: ENABLED${NC}"
else
  echo -e "${YELLOW}⚠ LibreOffice not found — Word/Excel/PPT conversion: DISABLED${NC}"
  echo -e "  Install: sudo apt install libreoffice  OR  brew install libreoffice"
fi

if command -v tesseract &> /dev/null; then
  echo -e "${GREEN}✓ Tesseract found    — Server-side OCR: ENABLED${NC}"
else
  echo -e "${YELLOW}⚠ Tesseract not found — Server-side OCR: DISABLED (browser OCR still works)${NC}"
  echo -e "  Install: sudo apt install tesseract-ocr"
fi

echo ""
echo -e "────────────────────────────────────────────────────────"
echo -e "${GREEN}🚀 Starting ToolXr backend...${NC}"
echo -e "${CYAN}   Frontend → http://localhost:3001/toolxr.html${NC}"
echo -e "${CYAN}   API      → http://localhost:3001/api/health${NC}"
echo -e "────────────────────────────────────────────────────────"
echo ""

# ── Start the backend ─────────────────────────────────────────────────────────
cd backend && node server.js
