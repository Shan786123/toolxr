/**
 * ToolXr Backend Server
 * Handles: Word↔PDF, Excel→PDF, PPT→PDF, HTML→PDF, Bulk Convert
 * Requires: Node.js 18+, LibreOffice installed
 *
 * Install deps:  npm install
 * Start:         node server.js
 * Dev mode:      node --watch server.js
 */

const express    = require('express');
const multer     = require('multer');
const cors       = require('cors');
const path       = require('path');
const fs         = require('fs');
const { exec }   = require('child_process');
const { promisify } = require('util');
const execAsync  = promisify(exec);

const app  = express();
const PORT = process.env.PORT || 3001;

// ── Middleware ────────────────────────────────────────────────────────────────
app.use(cors({ origin: '*' }));
app.use(express.json());

// Serve the frontend HTML statically
app.use(express.static(path.join(__dirname, '..')));

// ── Upload config ─────────────────────────────────────────────────────────────
const UPLOAD_DIR = path.join(__dirname, 'uploads');
const OUTPUT_DIR = path.join(__dirname, 'outputs');
[UPLOAD_DIR, OUTPUT_DIR].forEach(d => fs.mkdirSync(d, { recursive: true }));

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, UPLOAD_DIR),
  filename: (req, file, cb) => {
    const unique = Date.now() + '-' + Math.round(Math.random() * 1e6);
    cb(null, unique + path.extname(file.originalname));
  }
});
const upload = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 }, // 50MB limit
  fileFilter: (req, file, cb) => {
    const allowed = [
      '.pdf','.docx','.doc','.xlsx','.xls','.pptx','.ppt',
      '.html','.htm','.md','.csv','.txt',
      '.jpg','.jpeg','.png','.webp','.gif','.bmp','.tiff','.avif'
    ];
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, allowed.includes(ext));
  }
});

// ── Helper: run LibreOffice conversion ────────────────────────────────────────
async function libreofficeConvert(inputPath, outputDir, outputFormat = 'pdf') {
  const cmd = `libreoffice --headless --convert-to ${outputFormat} --outdir "${outputDir}" "${inputPath}"`;
  try {
    const { stdout, stderr } = await execAsync(cmd, { timeout: 60000 });
    const base  = path.basename(inputPath, path.extname(inputPath));
    const outFile = path.join(outputDir, `${base}.${outputFormat}`);
    if (!fs.existsSync(outFile)) throw new Error('Conversion produced no output');
    return outFile;
  } catch (err) {
    throw new Error('LibreOffice error: ' + (err.message || err));
  }
}

// ── Helper: cleanup temp files ────────────────────────────────────────────────
function cleanup(...files) {
  files.forEach(f => { try { if(f && fs.existsSync(f)) fs.unlinkSync(f); } catch(_){} });
}

// ── Helper: send file then delete ────────────────────────────────────────────
function sendAndClean(res, filePath, downloadName) {
  res.download(filePath, downloadName, err => {
    cleanup(filePath);
    if (err && !res.headersSent) res.status(500).json({ error: 'Download failed' });
  });
}

// ── ROUTES ────────────────────────────────────────────────────────────────────

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', version: '1.0.0', tools: 38 });
});

// ── Word to PDF ───────────────────────────────────────────────────────────────
app.post('/api/convert/word-to-pdf', upload.single('file'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
  const inputPath = req.file.path;
  try {
    const outFile = await libreofficeConvert(inputPath, OUTPUT_DIR);
    cleanup(inputPath);
    sendAndClean(res, outFile, 'converted.pdf');
  } catch (e) {
    cleanup(inputPath);
    res.status(500).json({ error: e.message });
  }
});

// ── PDF to Word ───────────────────────────────────────────────────────────────
app.post('/api/convert/pdf-to-word', upload.single('file'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
  const inputPath = req.file.path;
  try {
    const outFile = await libreofficeConvert(inputPath, OUTPUT_DIR, 'docx');
    cleanup(inputPath);
    sendAndClean(res, outFile, 'converted.docx');
  } catch (e) {
    cleanup(inputPath);
    res.status(500).json({ error: e.message });
  }
});

// ── Excel to PDF ──────────────────────────────────────────────────────────────
app.post('/api/convert/excel-to-pdf', upload.single('file'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
  const inputPath = req.file.path;
  try {
    const outFile = await libreofficeConvert(inputPath, OUTPUT_DIR);
    cleanup(inputPath);
    sendAndClean(res, outFile, 'spreadsheet.pdf');
  } catch (e) {
    cleanup(inputPath);
    res.status(500).json({ error: e.message });
  }
});

// ── PPT to PDF ────────────────────────────────────────────────────────────────
app.post('/api/convert/ppt-to-pdf', upload.single('file'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
  const inputPath = req.file.path;
  try {
    const outFile = await libreofficeConvert(inputPath, OUTPUT_DIR);
    cleanup(inputPath);
    sendAndClean(res, outFile, 'presentation.pdf');
  } catch (e) {
    cleanup(inputPath);
    res.status(500).json({ error: e.message });
  }
});

// ── HTML to PDF (using wkhtmltopdf or puppeteer) ──────────────────────────────
app.post('/api/convert/html-to-pdf', upload.single('file'), async (req, res) => {
  const htmlContent = req.body.html || (req.file ? fs.readFileSync(req.file.path,'utf8') : null);
  if (!htmlContent) return res.status(400).json({ error: 'No HTML content' });

  const tmpHtml = path.join(UPLOAD_DIR, `tmp-${Date.now()}.html`);
  const outPdf  = path.join(OUTPUT_DIR, `page-${Date.now()}.pdf`);
  fs.writeFileSync(tmpHtml, htmlContent);

  try {
    // Try wkhtmltopdf first, fallback to libreoffice
    await execAsync(`wkhtmltopdf "${tmpHtml}" "${outPdf}"`, { timeout: 30000 });
    cleanup(tmpHtml, req.file?.path);
    sendAndClean(res, outPdf, 'page.pdf');
  } catch {
    try {
      const outFile = await libreofficeConvert(tmpHtml, OUTPUT_DIR);
      cleanup(tmpHtml, req.file?.path);
      sendAndClean(res, outFile, 'page.pdf');
    } catch (e) {
      cleanup(tmpHtml, outPdf, req.file?.path);
      res.status(500).json({ error: 'Install wkhtmltopdf or LibreOffice: ' + e.message });
    }
  }
});

// ── Bulk Image Converter ──────────────────────────────────────────────────────
app.post('/api/convert/img-convert', upload.array('files', 50), async (req, res) => {
  if (!req.files?.length) return res.status(400).json({ error: 'No files' });
  const targetFmt = req.body.format || 'pdf';
  const results = [];
  try {
    for (const file of req.files) {
      const outFile = await libreofficeConvert(file.path, OUTPUT_DIR, targetFmt);
      results.push(outFile);
      cleanup(file.path);
    }
    // Zip all outputs
    const archivePath = path.join(OUTPUT_DIR, `batch-${Date.now()}.zip`);
    const zipList = results.map(f => `"${f}"`).join(' ');
    await execAsync(`zip -j "${archivePath}" ${zipList}`);
    results.forEach(f => cleanup(f));
    sendAndClean(res, archivePath, 'converted-batch.zip');
  } catch (e) {
    req.files.forEach(f => cleanup(f.path));
    results.forEach(f => cleanup(f));
    res.status(500).json({ error: e.message });
  }
});

// ── OCR endpoint (using Tesseract CLI) ───────────────────────────────────────
app.post('/api/ocr', upload.single('file'), async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file' });
  const inputPath = req.file.path;
  const outBase   = path.join(OUTPUT_DIR, `ocr-${Date.now()}`);
  try {
    await execAsync(`tesseract "${inputPath}" "${outBase}" -l eng`, { timeout: 60000 });
    const txtFile = outBase + '.txt';
    const text = fs.readFileSync(txtFile, 'utf8');
    cleanup(inputPath, txtFile);
    res.json({ text });
  } catch (e) {
    cleanup(inputPath);
    res.status(500).json({ error: 'Install Tesseract: sudo apt install tesseract-ocr — ' + e.message });
  }
});

// ── Auto-cleanup: delete files older than 30 minutes ─────────────────────────
setInterval(() => {
  const cutoff = Date.now() - 30 * 60 * 1000;
  [UPLOAD_DIR, OUTPUT_DIR].forEach(dir => {
    fs.readdirSync(dir).forEach(file => {
      const filePath = path.join(dir, file);
      try {
        const { mtimeMs } = fs.statSync(filePath);
        if (mtimeMs < cutoff) fs.unlinkSync(filePath);
      } catch(_) {}
    });
  });
}, 10 * 60 * 1000);

// ── Start ─────────────────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`\n🚀 ToolXr backend running at http://localhost:${PORT}`);
  console.log(`📂 Uploads dir : ${UPLOAD_DIR}`);
  console.log(`📂 Outputs dir : ${OUTPUT_DIR}`);
  console.log(`\n🔧 Required system tools:`);
  console.log(`   • LibreOffice : sudo apt install libreoffice`);
  console.log(`   • Tesseract   : sudo apt install tesseract-ocr`);
  console.log(`   • wkhtmltopdf : sudo apt install wkhtmltopdf  (optional)`);
  console.log(`\n🌐 Open frontend : http://localhost:${PORT}/toolxr.html\n`);
});
