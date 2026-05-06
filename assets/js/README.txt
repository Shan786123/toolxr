# assets/js/

This folder holds local copies of the JavaScript libraries used by ToolXr.

## Currently empty — two options:

### Option A: Keep using CDN (default, needs internet)
Leave this folder empty. toolxr.html loads libraries from:
  - cdnjs.cloudflare.com  (pdf-lib, PDF.js, FileSaver, JSZip)
  - cdn.jsdelivr.net       (Tesseract.js)

### Option B: Go fully offline (run the installer)
Run install-libs.sh (Mac/Linux) or install-libs.bat (Windows) from the
project root. It will download these files here automatically:

  pdf-lib.min.js       — PDF manipulation (Merge, Split, Compress, etc.)
  FileSaver.min.js     — File download handler
  jszip.min.js         — ZIP file creation (PDF to Image export)
  pdf.min.js           — PDF rendering (PDF to Image tool)
  pdf.worker.min.js    — PDF.js background worker
  tesseract.min.js     — OCR text extraction (client-side AI)

After running the installer, toolxr.html is patched to load from here
instead of CDN — works with zero internet connection.
