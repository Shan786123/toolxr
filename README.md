# ToolXr — 38 Free Tools · PDF · Image · Code · Convert

> Privacy-first browser toolkit. No sign-up. No data stored.
> All 33 core tools run entirely in your browser. 5 advanced tools use the included backend.

---

## 📂 What's in This Folder

```
toolxr/
├── index.html          ← YOUR WEBSITE (open this in any browser)
├── README.md            ← This file
├── start.sh             ← One-click start (Mac/Linux)
├── start.bat            ← One-click start (Windows)
├── nginx.conf           ← Production web server config
├── .gitignore           ← Git ignore rules
└── backend/
    ├── server.js        ← Node.js API server
    ├── package.json     ← npm package config
    ├── .env.example     ← Environment variables template
    ├── uploads/         ← Temp uploaded files (auto-deleted)
    └── outputs/         ← Temp converted files (auto-deleted)
```

---

## ⚡ Fastest Way to Start (No setup needed)

Double-click index.html — opens in your browser instantly.
33 out of 38 tools work immediately. No installation needed.

---

## 🔧 Full Setup (All 38 Tools)

5 tools need the Node.js backend: Word→PDF, Excel→PDF, PPT→PDF, PDF→Word, Bulk Converter

STEP 1 — Install Node.js:  https://nodejs.org  (click LTS)

STEP 2 — Install LibreOffice:
  Windows: https://www.libreoffice.org/download/
  Mac:     brew install libreoffice
  Linux:   sudo apt install -y libreoffice

STEP 3 — Start the server:
  Windows:     double-click start.bat
  Mac/Linux:   bash start.sh
  Manual:      cd backend && npm install && node server.js

STEP 4 — Open: http://localhost:3001/index.html

---

## 🌐 Quick Deploy

NETLIFY (free, 5 min):
  1. Go to app.netlify.com/drop
  2. Drag the toolxr/ folder onto the page
  3. Done — instant public URL!

VPS (all 38 tools):
  sudo apt install -y nodejs libreoffice tesseract-ocr nginx
  cd /var/www/toolxr/backend && npm install
  npm install -g pm2 && pm2 start server.js --name toolxr
  sudo cp nginx.conf /etc/nginx/sites-available/toolxr
  sudo ln -s /etc/nginx/sites-available/toolxr /etc/nginx/sites-enabled/
  sudo nginx -t && sudo systemctl reload nginx
  sudo certbot --nginx -d yourdomain.com

---

MIT License — free to use, modify, and deploy commercially.
