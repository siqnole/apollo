"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.judgeHtml = judgeHtml;
const jsdom_1 = require("jsdom");
// ── CSS value extractor ────────────────────────────────────────────────────
// Parses inline <style> blocks to check property values on selectors
function getCssProperty(css, selector, property) {
    // Very lightweight: looks for selector { ... property: value ... }
    const selectorEscaped = selector.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const block = new RegExp(`${selectorEscaped}\\s*\\{([^}]*)\\}`, 'gi');
    let match;
    let found = null;
    while ((match = block.exec(css)) !== null) {
        const propMatch = match[1].match(new RegExp(`${property}\\s*:\\s*([^;]+)`, 'i'));
        if (propMatch)
            found = propMatch[1].trim();
    }
    return found;
}
const CHECK_SUITES = {
    'flexbox-row-center': (dom, css) => {
        const doc = dom.window.document;
        const container = doc.querySelector('.container');
        const items = doc.querySelectorAll('.item');
        const display = getCssProperty(css, '.container', 'display');
        const justify = getCssProperty(css, '.container', 'justify-content');
        const align = getCssProperty(css, '.container', 'align-items');
        const height = getCssProperty(css, '.container', 'height');
        return [
            { label: '.container exists', passed: !!container, message: !container ? 'Missing .container element' : 'OK' },
            { label: 'display: flex', passed: display === 'flex', message: display === 'flex' ? 'OK' : `Got: ${display ?? 'none'}` },
            { label: 'justify-content set', passed: !!justify, message: !!justify ? `Got: ${justify}` : 'justify-content not set' },
            { label: 'align-items set', passed: !!align, message: !!align ? `Got: ${align}` : 'align-items not set' },
            { label: 'height: 200px', passed: height === '200px', message: height === '200px' ? 'OK' : `Got: ${height ?? 'not set'}` },
            { label: 'At least 3 .item children', passed: items.length >= 3, message: items.length >= 3 ? 'OK' : `Found ${items.length} .item element(s)` },
        ];
    },
    'css-grid-3x3': (dom, css) => {
        const doc = dom.window.document;
        const grid = doc.querySelector('.grid');
        const cells = doc.querySelectorAll('.cell');
        const display = getCssProperty(css, '.grid', 'display');
        const cols = getCssProperty(css, '.grid', 'grid-template-columns');
        const gap = getCssProperty(css, '.grid', 'gap') ?? getCssProperty(css, '.grid', 'grid-gap');
        const threeCol = cols ? (cols.match(/\b\S+/g) ?? []).length === 3 || cols.includes('repeat(3') : false;
        return [
            { label: '.grid exists', passed: !!grid, message: !!grid ? 'OK' : 'Missing .grid element' },
            { label: 'display: grid', passed: display === 'grid', message: display === 'grid' ? 'OK' : `Got: ${display ?? 'none'}` },
            { label: '3 columns defined', passed: threeCol, message: threeCol ? `Got: ${cols}` : 'grid-template-columns not 3 columns' },
            { label: 'Exactly 9 .cell children', passed: cells.length === 9, message: cells.length === 9 ? 'OK' : `Found ${cells.length} .cell element(s)` },
            { label: 'Gap between cells', passed: !!gap, message: !!gap ? `Got: ${gap}` : 'No gap set' },
        ];
    },
    'css-grid-uneven': (dom, css) => {
        const doc = dom.window.document;
        const cells = doc.querySelectorAll('.cell');
        const topGrid = doc.querySelector('.grid-top');
        const botGrid = doc.querySelector('.grid-bottom');
        const topCols = getCssProperty(css, '.grid-top', 'grid-template-columns');
        const botCols = getCssProperty(css, '.grid-bottom', 'grid-template-columns');
        const top3 = topCols ? (topCols.match(/\b\S+/g) ?? []).length === 3 || topCols.includes('repeat(3') : false;
        const bot4 = botCols ? (botCols.match(/\b\S+/g) ?? []).length === 4 || botCols.includes('repeat(4') : false;
        return [
            { label: '.grid-top exists', passed: !!topGrid, message: !!topGrid ? 'OK' : 'Missing .grid-top element' },
            { label: '.grid-bottom exists', passed: !!botGrid, message: !!botGrid ? 'OK' : 'Missing .grid-bottom element' },
            { label: 'Top grid has 3 columns', passed: top3, message: top3 ? `Got: ${topCols}` : 'grid-template-columns not 3 columns' },
            { label: 'Bottom grid has 4 columns', passed: bot4, message: bot4 ? `Got: ${botCols}` : 'grid-template-columns not 4 columns' },
            { label: 'At least 10 .cell elements', passed: cells.length >= 10, message: cells.length >= 10 ? 'OK' : `Found ${cells.length} .cell element(s)` },
        ];
    },
    'html-navbar': (dom) => {
        const doc = dom.window.document;
        const nav = doc.querySelector('nav');
        const ul = doc.querySelector('nav ul');
        const items = doc.querySelectorAll('nav li');
        const links = doc.querySelectorAll('nav a');
        return [
            { label: '<nav> element exists', passed: !!nav, message: !!nav ? 'OK' : 'Missing <nav> element' },
            { label: '<ul> inside nav', passed: !!ul, message: !!ul ? 'OK' : 'Missing <ul> inside <nav>' },
            { label: 'Exactly 4 <li> items', passed: items.length === 4, message: items.length === 4 ? 'OK' : `Found ${items.length} <li> element(s)` },
            { label: 'Each <li> has an <a>', passed: links.length === 4, message: links.length === 4 ? 'OK' : `Found ${links.length} <a> element(s)` },
        ];
    },
    'css-card': (dom, css) => {
        const doc = dom.window.document;
        const card = doc.querySelector('.card');
        const h2 = doc.querySelector('.card h2');
        const p = doc.querySelector('.card p');
        const radius = getCssProperty(css, '.card', 'border-radius');
        const shadow = getCssProperty(css, '.card', 'box-shadow');
        const padding = getCssProperty(css, '.card', 'padding');
        const maxW = getCssProperty(css, '.card', 'max-width');
        const radNum = radius ? parseInt(radius) : 0;
        const padNum = padding ? parseInt(padding) : 0;
        return [
            { label: '.card exists', passed: !!card, message: !!card ? 'OK' : 'Missing .card element' },
            { label: '<h2> inside card', passed: !!h2, message: !!h2 ? 'OK' : 'Missing <h2> inside .card' },
            { label: '<p> inside card', passed: !!p, message: !!p ? 'OK' : 'Missing <p> inside .card' },
            { label: 'border-radius ≥ 8px', passed: radNum >= 8, message: radNum >= 8 ? `Got: ${radius}` : `Got: ${radius ?? 'not set'}` },
            { label: 'box-shadow set', passed: !!shadow, message: !!shadow ? `Got: ${shadow}` : 'No box-shadow' },
            { label: 'padding ≥ 16px', passed: padNum >= 16, message: padNum >= 16 ? `Got: ${padding}` : `Got: ${padding ?? 'not set'}` },
            { label: 'max-width set', passed: !!maxW, message: !!maxW ? `Got: ${maxW}` : 'max-width not set' },
        ];
    },
    'flexbox-column': (dom, css) => {
        const doc = dom.window.document;
        const stack = doc.querySelector('.stack');
        const cards = doc.querySelectorAll('.stack .card');
        const display = getCssProperty(css, '.stack', 'display');
        const dir = getCssProperty(css, '.stack', 'flex-direction');
        const gap = getCssProperty(css, '.stack', 'gap');
        const width = getCssProperty(css, '.stack', 'width');
        return [
            { label: '.stack exists', passed: !!stack, message: !!stack ? 'OK' : 'Missing .stack element' },
            { label: 'display: flex', passed: display === 'flex', message: display === 'flex' ? 'OK' : `Got: ${display ?? 'none'}` },
            { label: 'flex-direction: column', passed: dir === 'column', message: dir === 'column' ? 'OK' : `Got: ${dir ?? 'not set'}` },
            { label: 'gap: 16px', passed: gap === '16px', message: gap === '16px' ? 'OK' : `Got: ${gap ?? 'not set'}` },
            { label: 'At least 3 .card items', passed: cards.length >= 3, message: cards.length >= 3 ? 'OK' : `Found ${cards.length} .card element(s)` },
        ];
    },
    'css-sticky-header': (dom, css) => {
        const doc = dom.window.document;
        const header = doc.querySelector('header');
        const position = getCssProperty(css, 'header', 'position');
        const top = getCssProperty(css, 'header', 'top');
        const bg = getCssProperty(css, 'header', 'background') ?? getCssProperty(css, 'header', 'background-color');
        const zIndex = getCssProperty(css, 'header', 'z-index');
        const isSticky = position === 'sticky' || position === 'fixed';
        return [
            { label: '<header> exists', passed: !!header, message: !!header ? 'OK' : 'Missing <header> element' },
            { label: 'sticky or fixed position', passed: isSticky, message: isSticky ? `Got: ${position}` : `Got: ${position ?? 'not set'}` },
            { label: 'top: 0', passed: top === '0' || top === '0px', message: (top === '0' || top === '0px') ? 'OK' : `Got: ${top ?? 'not set'}` },
            { label: 'Background colour set', passed: !!bg, message: !!bg ? `Got: ${bg}` : 'No background colour' },
            { label: 'z-index set', passed: !!zIndex, message: !!zIndex ? `Got: ${zIndex}` : 'z-index not set' },
        ];
    },
    'html-table': (dom) => {
        const doc = dom.window.document;
        const table = doc.querySelector('table');
        const thead = doc.querySelector('thead');
        const tbody = doc.querySelector('tbody');
        const ths = doc.querySelectorAll('th');
        const rows = doc.querySelectorAll('tbody tr');
        const tds = doc.querySelectorAll('td');
        return [
            { label: '<table> exists', passed: !!table, message: !!table ? 'OK' : 'Missing <table> element' },
            { label: '<thead> exists', passed: !!thead, message: !!thead ? 'OK' : 'Missing <thead>' },
            { label: '<tbody> exists', passed: !!tbody, message: !!tbody ? 'OK' : 'Missing <tbody>' },
            { label: '3 <th> headers', passed: ths.length === 3, message: ths.length === 3 ? 'OK' : `Found ${ths.length} <th> element(s)` },
            { label: 'At least 3 data rows', passed: rows.length >= 3, message: rows.length >= 3 ? 'OK' : `Found ${rows.length} row(s)` },
            { label: 'Cells have content', passed: tds.length >= 9, message: tds.length >= 9 ? 'OK' : `Found ${tds.length} <td> cell(s)` },
        ];
    },
    // ── ThreeJS validation suites ──────────────────────────────────────────
    'threejs-first-scene': (dom) => {
        const html = dom.serialize();
        const hasThreeImport = /import.*from.*three|<script[^>]*three/.test(html) || /THREE\s*\.|new\s+THREE\./.test(html);
        const hasScene = /new\s+THREE\.Scene\s*\(|\bScene\s*\(/.test(html);
        const hasCamera = /new\s+THREE\.(Perspective|Orthographic)Camera\s*\(|\b(Perspective|Orthographic)Camera\s*\(/.test(html);
        const hasRenderer = /new\s+THREE\.WebGLRenderer\s*\(|\bWebGLRenderer\s*\(/.test(html);
        const hasCanvas = /<canvas/.test(html);
        const hasRenderCall = /renderer\.render\s*\(|animate\s*\(|requestAnimationFrame/.test(html);
        const hasDOMAppend = /appendChild|document\.(body\.)?innerHTML|container\./.test(html);
        return [
            { label: 'Three.js imported/included', passed: hasThreeImport, message: hasThreeImport ? 'OK' : 'Three.js not found' },
            { label: 'Scene() instantiated', passed: hasScene, message: hasScene ? 'OK' : 'No Scene instance' },
            { label: 'Camera instantiated', passed: hasCamera, message: hasCamera ? 'OK' : 'No Camera instance' },
            { label: 'WebGLRenderer instantiated', passed: hasRenderer, message: hasRenderer ? 'OK' : 'No WebGLRenderer' },
            { label: 'Renderer added to DOM', passed: hasCanvas && hasDOMAppend, message: (hasCanvas && hasDOMAppend) ? 'OK' : 'Renderer not in DOM' },
            { label: 'Render loop active', passed: hasRenderCall, message: hasRenderCall ? 'OK' : 'No render loop' },
        ];
    },
    'threejs-sphere': (dom) => {
        const html = dom.serialize();
        const hasThreeImport = /import.*three|THREE\./.test(html);
        const hasScene = /new\s+THREE\.Scene\s*\(|\bScene\s*\(/.test(html);
        const hasCamera = /new\s+THREE\.PerspectiveCamera\s*\(/.test(html);
        const hasRenderer = /new\s+THREE\.WebGLRenderer\s*\(/.test(html);
        const hasSphereGeometry = /SphereGeometry\s*\(|\bSphere\s*\(/.test(html);
        const hasMeshCreation = /new\s+THREE\.Mesh\s*\(/.test(html);
        const hasMaterial = /(MeshBasicMaterial|MeshPhongMaterial|MeshStandardMaterial|MeshLambertMaterial)\s*\(/.test(html);
        const hasLightCreation = /(DirectionalLight|AmbientLight|PointLight|SpotLight)\s*\(/.test(html);
        const hasMeshAdd = /scene\.add\s*\(/.test(html);
        return [
            { label: 'Three.js imported', passed: hasThreeImport, message: hasThreeImport ? 'OK' : 'Three.js not found' },
            { label: 'Scene() instantiated', passed: hasScene, message: hasScene ? 'OK' : 'No Scene' },
            { label: 'PerspectiveCamera created', passed: hasCamera, message: hasCamera ? 'OK' : 'No PerspectiveCamera' },
            { label: 'WebGLRenderer created', passed: hasRenderer, message: hasRenderer ? 'OK' : 'No WebGLRenderer' },
            { label: 'Sphere geometry created', passed: hasSphereGeometry, message: hasSphereGeometry ? 'OK' : 'No SphereGeometry' },
            { label: 'Mesh with material', passed: hasMeshCreation && hasMaterial, message: (hasMeshCreation && hasMaterial) ? 'OK' : 'Mesh or material missing' },
            { label: 'Light and objects in scene', passed: hasLightCreation && hasMeshAdd, message: (hasLightCreation && hasMeshAdd) ? 'OK' : 'Missing lighting or scene.add()' },
        ];
    },
    'threejs-solar-system': (dom) => {
        const html = dom.serialize();
        const hasThreeImport = /import.*three|THREE\./.test(html);
        const hasScene = /new\s+THREE\.Scene\s*\(/.test(html);
        const sphereCount = (html.match(/SphereGeometry\s*\(/g) || []).length;
        const hasSpheres = sphereCount >= 2;
        const hasRotation = /\.rotation\s*[.=]|rotateOnWorldAxis|rotate[XYZ]\s*\(/.test(html);
        const hasAnimationLoop = /requestAnimationFrame\s*\(|function\s+animate\s*\(|(animate|update)\s*=\s*\(/.test(html);
        const hasLightCreation = /(DirectionalLight|AmbientLight|PointLight)\s*\(/.test(html);
        const hasSceneAdd = /scene\.add\s*\(/.test(html);
        return [
            { label: 'Three.js imported', passed: hasThreeImport, message: hasThreeImport ? 'OK' : 'Three.js not found' },
            { label: 'Scene created', passed: hasScene, message: hasScene ? 'OK' : 'No Scene' },
            { label: `${sphereCount}+ spheres (need 2+)`, passed: hasSpheres, message: hasSpheres ? `Found ${sphereCount}` : `Only ${sphereCount} sphere(s)` },
            { label: 'Rotation/orbital motion', passed: hasRotation, message: hasRotation ? 'OK' : 'No rotation' },
            { label: 'Animation loop (requestAnimationFrame)', passed: hasAnimationLoop, message: hasAnimationLoop ? 'OK' : 'No animation loop' },
            { label: 'Lighting and objects in scene', passed: hasLightCreation && hasSceneAdd, message: (hasLightCreation && hasSceneAdd) ? 'OK' : 'Missing lights or scene.add()' },
        ];
    },
    'threejs-orbit-camera': (dom) => {
        const html = dom.serialize();
        const hasCamera = /new\s+THREE\.PerspectiveCamera\s*\(/.test(html);
        const hasOrbitControls = /OrbitControls|orbit|controls\s*\(|controls\s*=/.test(html);
        const hasMouseListener = /(addEventListener|onmouse|pointerdown|pointerup|pointermove|wheel)\s*[=\(]/.test(html);
        const hasCameraPositioned = /camera\.position\s*[.=]|position\s*\.\s*set\s*\(|position\s*\+=/.test(html);
        const hasLookAt = /camera\.lookAt\s*\(|target\s*[.=]|\btarget\s*=/.test(html);
        return [
            { label: 'PerspectiveCamera instance', passed: hasCamera, message: hasCamera ? 'OK' : 'No PerspectiveCamera' },
            { label: 'Controls/OrbitControls', passed: hasOrbitControls, message: hasOrbitControls ? 'OK' : 'No camera controls' },
            { label: 'Mouse event listeners', passed: hasMouseListener, message: hasMouseListener ? 'OK' : 'No mouse events' },
            { label: 'Camera position configured', passed: hasCameraPositioned, message: hasCameraPositioned ? 'OK' : 'Camera.position not set' },
            { label: 'Camera target/lookAt', passed: hasLookAt, message: hasLookAt ? 'OK' : 'No lookAt() or target' },
        ];
    },
    'threejs-fps-camera': (dom) => {
        const html = dom.serialize();
        const hasCamera = /new\s+THREE\.PerspectiveCamera\s*\(|PerspectiveCamera\s*\(/.test(html);
        const hasKeyboardTracking = /(keys\s*\[|keysPressed|addEventListener\s*\(\s*['"]key).*(keydown|keyup)/i.test(html) || /key(down|up).*addEventListener/i.test(html);
        const hasMovement = /velocity\s*[.=]|position\.add\s*\(|translate[XYZ]\s*\(|position\s*\+=/.test(html);
        const hasMouseMovement = /(onmouse|addEventListener.*mouse|pointerlock|requestPointerLock)/.test(html) && /(pitch|yaw|euler|rotation\s*[.x.y])/.test(html);
        const hasUpdateLogic = /(update|tick|animate)\s*\(.*\{|if\s*\(\s*keys/.test(html);
        return [
            { label: 'PerspectiveCamera instance', passed: hasCamera, message: hasCamera ? 'OK' : 'No PerspectiveCamera' },
            { label: 'Keyboard input (keydown/keyup)', passed: hasKeyboardTracking, message: hasKeyboardTracking ? 'OK' : 'No keyboard tracking' },
            { label: 'Movement/velocity system', passed: hasMovement, message: hasMovement ? 'OK' : 'No position.add() or movement' },
            { label: 'Mouse look (pitch/yaw)', passed: hasMouseMovement, message: hasMouseMovement ? 'OK' : 'No mouse look' },
            { label: 'Update/animate with controls', passed: hasUpdateLogic, message: hasUpdateLogic ? 'OK' : 'No update loop' },
        ];
    },
    'threejs-shadows': (dom) => {
        const html = dom.serialize();
        // Check renderer has shadowMap enabled
        const hasRendererShadows = /renderer\.shadowMap\.enabled\s*=\s*true|shadowMap\s*:\s*\{\s*enabled\s*:\s*true/.test(html);
        // Check for DirectionalLight or SpotLight with castShadow
        const hasLightWithShadow = /(DirectionalLight|SpotLight)\s*\(/.test(html) && /castShadow\s*[.=]\s*(true|1)/.test(html);
        // Check mesh has castShadow = true
        const hasMeshCastShadow = /castShadow\s*[.=]\s*(true|1)/.test(html) && /new\s+THREE\.Mesh/.test(html);
        // Check for receiveShadow on geometry/plane
        const hasReceiveShadow = /receiveShadow\s*[.=]\s*(true|1)/.test(html);
        // Check shadow camera is configured
        const hasShadowCameraConfig = /(shadow\.camera\s*[.=]|shadow\.mapSize|shadow\.map)/.test(html);
        return [
            { label: 'Renderer shadowMap enabled', passed: hasRendererShadows, message: hasRendererShadows ? 'OK' : 'renderer.shadowMap.enabled not true' },
            { label: 'Light has castShadow enabled', passed: hasLightWithShadow, message: hasLightWithShadow ? 'OK' : 'Light missing castShadow = true' },
            { label: 'Mesh/object castShadow enabled', passed: hasMeshCastShadow, message: hasMeshCastShadow ? 'OK' : 'Mesh missing castShadow = true' },
            { label: 'Surface receiveShadow enabled', passed: hasReceiveShadow, message: hasReceiveShadow ? 'OK' : 'No receiveShadow = true' },
            { label: 'Shadow camera/mapSize configured', passed: hasShadowCameraConfig, message: hasShadowCameraConfig ? 'OK' : 'Shadow properties not configured' },
        ];
    },
};
// ── Main export ────────────────────────────────────────────────────────────
function judgeHtml(slug, html) {
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
    let dom;
    try {
        dom = new jsdom_1.JSDOM(html);
    }
    catch {
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
