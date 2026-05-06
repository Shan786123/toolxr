#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# ToolXr — Install Libraries Locally (Offline Mode)
# Run this once to download all CDN libraries locally.
# After this, toolxr.html works with NO internet connection.
#
# Usage: bash install-libs.sh
# ─────────────────────────────────────────────────────────────────────────────

set -e
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'

echo ""
echo -e "${BOLD}${CYAN}ToolXr — Offline Library Installer${NC}"
echo -e "────────────────────────────────────────"
echo -e "Downloads all CDN scripts so the site works without internet."
echo ""

# ── Create assets folder ──────────────────────────────────────────────────────
mkdir -p assets/js assets/fonts

# ── Check curl ────────────────────────────────────────────────────────────────
if ! command -v curl &>/dev/null; then
  echo -e "${RED}✗ curl not found. Install it first:${NC}"
  echo "  Linux:  sudo apt install curl"
  echo "  Mac:    brew install curl"
  exit 1
fi

# ── Download JS libraries ─────────────────────────────────────────────────────
download() {
  local name="$1" url="$2" file="$3"
  echo -ne "  Downloading ${name}..."
  if curl -sL --max-time 30 "$url" -o "$file"; then
    local size=$(wc -c < "$file")
    if [ "$size" -lt 1000 ]; then
      echo -e " ${RED}✗ file too small ($size bytes) — check URL${NC}"
      return 1
    fi
    echo -e " ${GREEN}✓ $(echo "$size / 1024" | bc)KB${NC}"
  else
    echo -e " ${RED}✗ failed${NC}"
    return 1
  fi
}

echo -e "${BOLD}Downloading JS libraries...${NC}"
download "pdf-lib"      "https://cdnjs.cloudflare.com/ajax/libs/pdf-lib/1.17.1/pdf-lib.min.js"          "assets/js/pdf-lib.min.js"
download "FileSaver"    "https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/2.0.5/FileSaver.min.js"    "assets/js/FileSaver.min.js"
download "JSZip"        "https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"              "assets/js/jszip.min.js"
download "PDF.js"       "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"             "assets/js/pdf.min.js"
download "PDF.js worker" "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js"    "assets/js/pdf.worker.min.js"
download "Tesseract.js" "https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js"             "assets/js/tesseract.min.js"

echo ""
echo -e "${BOLD}Downloading fonts (optional)...${NC}"
download "Space Mono (regular)" "https://fonts.gstatic.com/s/spacemono/v13/i7dPIFZifjKcF5UAWdDRUEZ2RFq7AwU.woff2" "assets/fonts/SpaceMono-Regular.woff2" || true
download "Space Mono (bold)"    "https://fonts.gstatic.com/s/spacemono/v13/i7dQIFZifjKcF5UAWdDRYER8QHi-EwWMbg.woff2" "assets/fonts/SpaceMono-Bold.woff2" || true
download "DM Sans"              "https://fonts.gstatic.com/s/dmsans/v15/rP2Hp2ywxg089UriCZOIHQ.woff2" "assets/fonts/DMSans.woff2" || true

# ── Patch toolxr.html to use local files ─────────────────────────────────────
echo ""
echo -e "${BOLD}Patching toolxr.html to use local files...${NC}"

# Backup original
cp toolxr.html toolxr.html.bak
echo -e "  ${YELLOW}⚠ Backup saved as toolxr.html.bak${NC}"

# Replace CDN URLs with local paths
sed -i \
  -e 's|https://cdnjs.cloudflare.com/ajax/libs/pdf-lib/1.17.1/pdf-lib.min.js|assets/js/pdf-lib.min.js|g' \
  -e 's|https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/2.0.5/FileSaver.min.js|assets/js/FileSaver.min.js|g' \
  -e 's|https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js|assets/js/jszip.min.js|g' \
  -e 's|https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js|assets/js/pdf.min.js|g' \
  -e "s|https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js|assets/js/pdf.worker.min.js|g" \
  -e 's|https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js|assets/js/tesseract.min.js|g' \
  toolxr.html

# Replace Google Fonts with local fonts (if downloaded)
if [ -f "assets/fonts/SpaceMono-Regular.woff2" ]; then
  # Remove Google Fonts link tag and inject local @font-face
  sed -i "s|<link href=\"https://fonts.googleapis.com.*\".*>|<style>@font-face{font-family:'Space Mono';font-weight:400;src:url('assets/fonts/SpaceMono-Regular.woff2') format('woff2')}@font-face{font-family:'Space Mono';font-weight:700;src:url('assets/fonts/SpaceMono-Bold.woff2') format('woff2')}@font-face{font-family:'DM Sans';font-weight:300 600;src:url('assets/fonts/DMSans.woff2') format('woff2')}</style>|" toolxr.html
  echo -e "  ${GREEN}✓ Fonts patched to local files${NC}"
else
  echo -e "  ${YELLOW}⚠ Fonts not downloaded — keeping Google Fonts CDN${NC}"
fi

echo -e "  ${GREEN}✓ toolxr.html patched${NC}"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "────────────────────────────────────────"
echo -e "${GREEN}${BOLD}✅ Done! ToolXr is now fully offline.${NC}"
echo ""
echo -e "Serve with:  ${CYAN}npx serve .${NC}  then open  ${CYAN}http://localhost:3000/toolxr.html${NC}"
echo -e "Or open:     ${CYAN}toolxr.html${NC}  directly in your browser"
echo ""
echo -e "${YELLOW}Note: Remove Background tool still needs internet (calls remove.bg API).${NC}"
echo -e "${YELLOW}      All other 37 tools work 100% offline.${NC}"
echo ""
