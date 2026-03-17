// src/utils/downloadPdf.ts
// Client-side PDF generation from a rendered DOM element.
// Captures the element exactly as it looks (KaTeX, code blocks, etc.)
// then lays it across A4 pages.
//
// Install deps (if not already present):
//   npm install jspdf html2canvas

import jsPDF from 'jspdf';
import html2canvas from 'html2canvas';

interface DownloadOptions {
  element:   HTMLElement;   // the DOM node to capture
  filename:  string;        // e.g. "two-sum.pdf"
  title?:    string;        // optional header text on first page
  difficulty?: string;
  category?:  string;
  xpReward?:  number;
}

const A4_WIDTH_MM  = 210;
const A4_HEIGHT_MM = 297;
const MARGIN_MM    = 14;
const CONTENT_W_MM = A4_WIDTH_MM - MARGIN_MM * 2;

// Apollo palette
const GOLD   = '#C9A84C';
const BG     = '#0A0906';
const MUTED  = '#8A7D65';
const DIM    = '#4A4236';

const DIFF_COLORS: Record<string, string> = {
  Easy:   '#2AC87D',
  Medium: '#C9A84C',
  Hard:   '#E05C2A',
  Expert: '#C82A2A',
};

export async function downloadProblemPdf(opts: DownloadOptions): Promise<void> {
  const { element, filename, title, difficulty, category, xpReward } = opts;

  // ── 1. Capture the rendered element ─────────────────────────────────────
  const canvas = await html2canvas(element, {
    scale:           2,            // retina sharpness
    useCORS:         true,
    backgroundColor: '#0F0D09',    // Apollo bg2
    logging:         false,
    windowWidth:     element.scrollWidth,
    windowHeight:    element.scrollHeight,
  });

  const pdf = new jsPDF({
    orientation: 'portrait',
    unit:        'mm',
    format:      'a4',
  });

  const pageW  = pdf.internal.pageSize.getWidth();
  const pageH  = pdf.internal.pageSize.getHeight();

  // ── 2. Dark background on every page ────────────────────────────────────
  const drawBackground = () => {
    pdf.setFillColor(10, 9, 6);   // #0A0906
    pdf.rect(0, 0, pageW, pageH, 'F');
  };

  // ── 3. Header (first page only) ──────────────────────────────────────────
  const HEADER_H = title ? 28 : 0;

  const drawHeader = () => {
    if (!title) return;

    // Top accent line
    pdf.setDrawColor(201, 168, 76);
    pdf.setLineWidth(0.4);
    pdf.line(MARGIN_MM, MARGIN_MM + 6, pageW - MARGIN_MM, MARGIN_MM + 6);

    // APOLLO wordmark
    pdf.setFont('helvetica', 'bold');
    pdf.setFontSize(7);
    pdf.setTextColor(201, 168, 76);
    pdf.text('APOLLO.GG', MARGIN_MM, MARGIN_MM + 3.5);

    // Problem title
    pdf.setFont('helvetica', 'bold');
    pdf.setFontSize(16);
    pdf.setTextColor(240, 232, 214);
    pdf.text(title, MARGIN_MM, MARGIN_MM + 14);

    // Meta row: difficulty · category · XP
    let metaX = MARGIN_MM;
    const metaY = MARGIN_MM + 20;
    pdf.setFontSize(7.5);
    pdf.setFont('helvetica', 'normal');

    if (difficulty) {
      const col = DIFF_COLORS[difficulty] ?? GOLD;
      const rgb = hexToRgb(col);
      pdf.setTextColor(rgb.r, rgb.g, rgb.b);
      pdf.text(difficulty.toUpperCase(), metaX, metaY);
      metaX += pdf.getTextWidth(difficulty.toUpperCase()) + 5;
    }
    if (category) {
      pdf.setTextColor(138, 125, 101);
      pdf.text(category, metaX, metaY);
      metaX += pdf.getTextWidth(category) + 5;
    }
    if (xpReward != null) {
      pdf.setTextColor(201, 168, 76);
      pdf.text(`+${xpReward} XP`, metaX, metaY);
    }

    // Bottom rule
    pdf.setDrawColor(74, 66, 54);
    pdf.setLineWidth(0.25);
    pdf.line(MARGIN_MM, MARGIN_MM + 23, pageW - MARGIN_MM, MARGIN_MM + 23);
  };

  // ── 4. Footer on every page ──────────────────────────────────────────────
  const drawFooter = (pageNum: number, totalPages: number) => {
    const y = pageH - 7;
    pdf.setDrawColor(74, 66, 54);
    pdf.setLineWidth(0.2);
    pdf.line(MARGIN_MM, y - 2, pageW - MARGIN_MM, y - 2);
    pdf.setFontSize(6.5);
    pdf.setFont('helvetica', 'normal');
    pdf.setTextColor(74, 66, 54);
    pdf.text('apollo.gg', MARGIN_MM, y);
    pdf.text(`${pageNum} / ${totalPages}`, pageW - MARGIN_MM, y, { align: 'right' });
  };

  // ── 5. Slice the canvas across A4 pages ──────────────────────────────────
  const imgData     = canvas.toDataURL('image/png');
  const imgWidthMM  = CONTENT_W_MM;
  const imgFullH_MM = (canvas.height / canvas.width) * imgWidthMM;

  const firstContentY  = MARGIN_MM + HEADER_H + 2;
  const firstContentH  = pageH - firstContentY - 12;   // 12mm for footer
  const otherContentH  = pageH - MARGIN_MM - 12;

  let srcOffsetMM = 0;
  let page        = 1;

  // Count pages first
  let totalPages = 1;
  let remaining  = imgFullH_MM - firstContentH;
  while (remaining > 0) { totalPages++; remaining -= otherContentH; }

  // Render pages
  while (srcOffsetMM < imgFullH_MM) {
    drawBackground();

    const isFirst     = page === 1;
    const contentY    = isFirst ? firstContentY : MARGIN_MM;
    const contentH    = isFirst ? firstContentH : otherContentH;
    const sliceH      = Math.min(contentH, imgFullH_MM - srcOffsetMM);

    // Source rect in canvas pixels
    const scaleX   = canvas.width  / imgWidthMM;
    const scaleY   = canvas.height / imgFullH_MM;
    const srcY_px  = srcOffsetMM * scaleY;
    const srcH_px  = sliceH      * scaleY;

    // Create a temporary canvas for the slice
    const sliceCanvas        = document.createElement('canvas');
    sliceCanvas.width        = canvas.width;
    sliceCanvas.height       = Math.ceil(srcH_px);
    const ctx                = sliceCanvas.getContext('2d')!;
    ctx.drawImage(canvas, 0, -srcY_px);

    const sliceData = sliceCanvas.toDataURL('image/png');
    pdf.addImage(sliceData, 'PNG', MARGIN_MM, contentY, imgWidthMM, sliceH);

    if (isFirst) drawHeader();
    drawFooter(page, totalPages);

    srcOffsetMM += sliceH;
    if (srcOffsetMM < imgFullH_MM) {
      pdf.addPage();
      page++;
    }
  }

  pdf.save(filename);
}

// ── Helpers ──────────────────────────────────────────────────────────────
function hexToRgb(hex: string): { r: number; g: number; b: number } {
  const clean = hex.replace('#', '');
  return {
    r: parseInt(clean.substring(0, 2), 16),
    g: parseInt(clean.substring(2, 4), 16),
    b: parseInt(clean.substring(4, 6), 16),
  };
}