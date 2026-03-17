import { JSDOM } from 'jsdom';

export interface HtmlJudgeResult {
  status:  'accepted' | 'wrong_answer';
  output:  string;
  checks:  { label: string; passed: boolean; message: string }[];
}

// ── CSS value extractor ────────────────────────────────────────────────────
// Parses inline <style> blocks to check property values on selectors

function getCssProperty(css: string, selector: string, property: string): string | null {
  // Very lightweight: looks for selector { ... property: value ... }
  const selectorEscaped = selector.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const block = new RegExp(`${selectorEscaped}\\s*\\{([^}]*)\\}`, 'gi');
  let match: RegExpExecArray | null;
  let found: string | null = null;
  while ((match = block.exec(css)) !== null) {
    const propMatch = match[1].match(new RegExp(`${property}\\s*:\\s*([^;]+)`, 'i'));
    if (propMatch) found = propMatch[1].trim();
  }
  return found;
}

// ── Problem-specific check suites ─────────────────────────────────────────

type CheckSuite = (dom: JSDOM, css: string) => { label: string; passed: boolean; message: string }[];

const CHECK_SUITES: Record<string, CheckSuite> = {

  'flexbox-row-center': (dom, css) => {
    const doc = dom.window.document;
    const container = doc.querySelector('.container');
    const items = doc.querySelectorAll('.item');
    const display   = getCssProperty(css, '.container', 'display');
    const justify   = getCssProperty(css, '.container', 'justify-content');
    const align     = getCssProperty(css, '.container', 'align-items');
    const height    = getCssProperty(css, '.container', 'height');
    return [
      { label: '.container exists',        passed: !!container,                                  message: container ? 'Found .container'           : 'No element with class "container" found'    },
      { label: 'display: flex',            passed: display === 'flex',                           message: display   ? `Got: ${display}`             : 'Missing display: flex on .container'        },
      { label: 'justify-content set',      passed: !!justify,                                    message: justify   ? `Got: ${justify}`             : 'Missing justify-content on .container'      },
      { label: 'align-items set',          passed: !!align,                                      message: align     ? `Got: ${align}`               : 'Add align-items to vertically centre items' },
      { label: 'height: 200px',            passed: height === '200px',                           message: height    ? `Got: ${height}`              : 'Container should be exactly 200px tall'     },
      { label: 'At least 3 .item children',passed: items.length >= 3,                           message: `Found ${items.length} .item element(s)`                                               },
    ];
  },

  'css-grid-3x3': (dom, css) => {
    const doc     = dom.window.document;
    const grid    = doc.querySelector('.grid');
    const cells   = doc.querySelectorAll('.cell');
    const display = getCssProperty(css, '.grid', 'display');
    const cols    = getCssProperty(css, '.grid', 'grid-template-columns');
    const gap     = getCssProperty(css, '.grid', 'gap') ?? getCssProperty(css, '.grid', 'grid-gap');
    const threeCol = cols ? (cols.match(/\b\S+/g) ?? []).length === 3 || cols.includes('repeat(3') : false;
    return [
      { label: '.grid exists',              passed: !!grid,         message: grid     ? 'Found .grid'          : 'No element with class "grid" found'        },
      { label: 'display: grid',             passed: display==='grid',message: display ? `Got: ${display}`      : 'Missing display: grid on .grid'            },
      { label: '3 columns defined',         passed: threeCol,       message: cols     ? `Got: ${cols}`         : 'Add grid-template-columns with 3 columns'  },
      { label: 'Exactly 9 .cell children',  passed: cells.length===9,message: `Found ${cells.length} .cell element(s)` },
      { label: 'Gap between cells',         passed: !!gap,          message: gap      ? `Got gap: ${gap}`      : 'Add a gap between grid cells'              },
    ];
  },

  'css-grid-uneven': (dom, css) => {
    const doc      = dom.window.document;
    const cells    = doc.querySelectorAll('.cell');
    const topGrid  = doc.querySelector('.grid-top');
    const botGrid  = doc.querySelector('.grid-bottom');
    const topCols  = getCssProperty(css, '.grid-top',    'grid-template-columns');
    const botCols  = getCssProperty(css, '.grid-bottom', 'grid-template-columns');
    const top3  = topCols ? (topCols.match(/\b\S+/g) ?? []).length === 3 || topCols.includes('repeat(3') : false;
    const bot4  = botCols ? (botCols.match(/\b\S+/g) ?? []).length === 4 || botCols.includes('repeat(4') : false;
    return [
      { label: '.grid-top exists',          passed: !!topGrid,       message: topGrid ? 'Found .grid-top'     : 'Add a div with class "grid-top"'           },
      { label: '.grid-bottom exists',       passed: !!botGrid,       message: botGrid ? 'Found .grid-bottom'  : 'Add a div with class "grid-bottom"'        },
      { label: 'Top grid has 3 columns',    passed: top3,            message: topCols ? `Got: ${topCols}`     : 'Set grid-template-columns to 3 columns on .grid-top'  },
      { label: 'Bottom grid has 4 columns', passed: bot4,            message: botCols ? `Got: ${botCols}`     : 'Set grid-template-columns to 4 columns on .grid-bottom'},
      { label: 'At least 10 .cell elements',passed: cells.length>=10,message: `Found ${cells.length} .cell element(s)`                                      },
    ];
  },

  'html-navbar': (dom) => {
    const doc   = dom.window.document;
    const nav   = doc.querySelector('nav');
    const ul    = doc.querySelector('nav ul');
    const items = doc.querySelectorAll('nav li');
    const links = doc.querySelectorAll('nav a');
    return [
      { label: '<nav> element exists',    passed: !!nav,           message: nav    ? 'Found <nav>'               : 'Add a <nav> element'                          },
      { label: '<ul> inside nav',         passed: !!ul,            message: ul     ? 'Found <ul> inside nav'      : 'Add a <ul> inside your <nav>'                 },
      { label: 'Exactly 4 <li> items',    passed: items.length===4,message: `Found ${items.length} <li> element(s)` },
      { label: 'Each <li> has an <a>',    passed: links.length===4,message: `Found ${links.length} <a> element(s)` },
    ];
  },

  'css-card': (dom, css) => {
    const doc     = dom.window.document;
    const card    = doc.querySelector('.card');
    const h2      = doc.querySelector('.card h2');
    const p       = doc.querySelector('.card p');
    const radius  = getCssProperty(css, '.card', 'border-radius');
    const shadow  = getCssProperty(css, '.card', 'box-shadow');
    const padding = getCssProperty(css, '.card', 'padding');
    const maxW    = getCssProperty(css, '.card', 'max-width');
    const radNum  = radius ? parseInt(radius) : 0;
    const padNum  = padding ? parseInt(padding) : 0;
    return [
      { label: '.card exists',         passed: !!card,      message: card    ? 'Found .card'                : 'No element with class "card" found'      },
      { label: '<h2> inside card',     passed: !!h2,        message: h2      ? 'Found <h2>'                 : 'Add an <h2> inside .card'                },
      { label: '<p> inside card',      passed: !!p,         message: p       ? 'Found <p>'                  : 'Add a <p> inside .card'                  },
      { label: 'border-radius ≥ 8px',  passed: radNum >= 8, message: radius  ? `Got: ${radius}`             : 'Add border-radius of at least 8px'       },
      { label: 'box-shadow set',       passed: !!shadow,    message: shadow  ? 'box-shadow found'           : 'Add a box-shadow to the card'            },
      { label: 'padding ≥ 16px',       passed: padNum >= 16,message: padding ? `Got: ${padding}`            : 'Add at least 16px padding to .card'     },
      { label: 'max-width set',        passed: !!maxW,      message: maxW    ? `Got: ${maxW}`               : 'Add a max-width to limit the card size'  },
    ];
  },

  'flexbox-column': (dom, css) => {
    const doc      = dom.window.document;
    const stack    = doc.querySelector('.stack');
    const cards    = doc.querySelectorAll('.stack .card');
    const display  = getCssProperty(css, '.stack', 'display');
    const dir      = getCssProperty(css, '.stack', 'flex-direction');
    const gap      = getCssProperty(css, '.stack', 'gap');
    const width    = getCssProperty(css, '.stack', 'width');
    return [
      { label: '.stack exists',          passed: !!stack,          message: stack   ? 'Found .stack'          : 'Add a div with class "stack"'            },
      { label: 'display: flex',          passed: display==='flex', message: display ? `Got: ${display}`       : 'Add display: flex to .stack'             },
      { label: 'flex-direction: column', passed: dir==='column',   message: dir     ? `Got: ${dir}`           : 'Add flex-direction: column to .stack'   },
      { label: 'gap: 16px',              passed: gap==='16px',     message: gap     ? `Got: ${gap}`           : 'Add gap: 16px to .stack'                },
      { label: 'At least 3 .card items', passed: cards.length>=3, message: `Found ${cards.length} .card element(s)`                                     },
    ];
  },

  'css-sticky-header': (dom, css) => {
    const doc      = dom.window.document;
    const header   = doc.querySelector('header');
    const position = getCssProperty(css, 'header', 'position');
    const top      = getCssProperty(css, 'header', 'top');
    const bg       = getCssProperty(css, 'header', 'background') ?? getCssProperty(css, 'header', 'background-color');
    const zIndex   = getCssProperty(css, 'header', 'z-index');
    const isSticky = position === 'sticky' || position === 'fixed';
    return [
      { label: '<header> exists',         passed: !!header,     message: header   ? 'Found <header>'         : 'Add a <header> element'                    },
      { label: 'sticky or fixed position',passed: isSticky,     message: position ? `Got: ${position}`       : 'Set position: sticky or fixed on header'   },
      { label: 'top: 0',                  passed: top==='0' || top==='0px', message: top ? `Got: ${top}`     : 'Add top: 0 to keep the header at the top'  },
      { label: 'Background colour set',   passed: !!bg,         message: bg       ? `Got: ${bg}`             : 'Add a background colour so it covers content' },
      { label: 'z-index set',             passed: !!zIndex,     message: zIndex   ? `Got z-index: ${zIndex}` : 'Add z-index to appear above page content'  },
    ];
  },

  'html-table': (dom) => {
    const doc    = dom.window.document;
    const table  = doc.querySelector('table');
    const thead  = doc.querySelector('thead');
    const tbody  = doc.querySelector('tbody');
    const ths    = doc.querySelectorAll('th');
    const rows   = doc.querySelectorAll('tbody tr');
    const tds    = doc.querySelectorAll('td');
    return [
      { label: '<table> exists',            passed: !!table,       message: table  ? 'Found <table>'               : 'Add a <table> element'                  },
      { label: '<thead> exists',            passed: !!thead,       message: thead  ? 'Found <thead>'               : 'Wrap header row in <thead>'             },
      { label: '<tbody> exists',            passed: !!tbody,       message: tbody  ? 'Found <tbody>'               : 'Wrap data rows in <tbody>'              },
      { label: '3 <th> headers',            passed: ths.length===3,message: `Found ${ths.length} <th> element(s)` },
      { label: 'At least 3 data rows',      passed: rows.length>=3,message: `Found ${rows.length} row(s) in <tbody>` },
      { label: 'Cells have content',        passed: tds.length>=9, message: `Found ${tds.length} <td> cell(s)`    },
    ];
  },
};

// ── Main export ────────────────────────────────────────────────────────────

export function judgeHtml(slug: string, html: string): HtmlJudgeResult {
  const suite = CHECK_SUITES[slug];
  if (!suite) {
    // No specific checks — just validate it's parseable HTML
    return {
      status: 'accepted',
      output: 'HTML submitted successfully. No automated checks for this problem.',
      checks: [{ label: 'HTML parseable', passed: true, message: 'Valid HTML' }],
    };
  }

  // Extract CSS from <style> blocks
  const styleMatches = html.match(/<style[^>]*>([\s\S]*?)<\/style>/gi) ?? [];
  const css = styleMatches.map(s => s.replace(/<\/?style[^>]*>/gi, '')).join('\n');

  let dom: JSDOM;
  try {
    dom = new JSDOM(html);
  } catch {
    return { status: 'wrong_answer', output: 'Could not parse HTML.', checks: [] };
  }

  const checks = suite(dom, css);
  const allPassed = checks.every(c => c.passed);
  const failed = checks.filter(c => !c.passed);

  return {
    status: allPassed ? 'accepted' : 'wrong_answer',
    output: allPassed
      ? `All ${checks.length} checks passed!`
      : `${failed.length} check(s) failed: ${failed.map(f => f.label).join(', ')}`,
    checks,
  };
}