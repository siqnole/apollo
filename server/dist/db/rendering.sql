-- ── OpenGL & Game Rendering Problems ────────────────────────────────────
-- Run: psql -U postgres -d apollo -h localhost -f rendering_problems.sql
--
-- All problems are html_css type — the live iframe preview IS the output.
-- Grading checks for the presence of key DOM/canvas elements via the sandbox.
-- Three.js is loaded from cdnjs (r128) in all Three.js starters.
--
-- Tiers:
--   Tier 1 (Easy)          — 2D canvas fundamentals
--   Tier 2 (Medium)        — Three.js basics, scenes, geometry
--   Tier 3 (Hard)          — Lighting, cameras, animation
--   Tier 4 (Expert)        — Shaders, post-processing, custom systems

ALTER TYPE problem_type ADD VALUE IF NOT EXISTS 'html_css';


-- ══════════════════════════════════════════════════════════════════════════
-- TIER 1 — 2D CANVAS FUNDAMENTALS
-- ══════════════════════════════════════════════════════════════════════════

-- ── 1a. Render a circle ──────────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'canvas-circle',
  'Render a Circle',
  E'Draw a **filled circle** on an HTML5 canvas.\n\n**Requirements:**\n- A `<canvas>` element fills the page\n- A circle centred in the canvas\n- Radius at least **80px**\n- Filled with any solid colour\n- Canvas background is dark (not white)\n\nThis is the "Hello World" of graphics programming.',
  'html_css', 'Easy', 'Game Dev', 60,
  $sc${"html": "<!DOCTYPE html>\n<html>\n<head>\n  <style>\n    * { margin: 0; padding: 0; box-sizing: border-box; }\n    body { background: #0A0906; display: flex; align-items: center; justify-content: center; height: 100vh; }\n    canvas { display: block; }\n  </style>\n</head>\n<body>\n  <canvas id=\"c\"></canvas>\n  <script>\n    const canvas = document.getElementById('c');\n    const ctx = canvas.getContext('2d');\n    canvas.width  = window.innerWidth;\n    canvas.height = window.innerHeight;\n\n    // Draw a filled circle here\n    // Hint: ctx.arc(x, y, radius, 0, Math.PI * 2)\n\n  </script>\n</body>\n</html>"}$sc$,
  ARRAY['ctx.beginPath() starts a new path', 'ctx.arc(x, y, radius, startAngle, endAngle) defines the circle', 'ctx.fillStyle sets the colour, ctx.fill() fills it', 'Centre: canvas.width/2, canvas.height/2'],
  ARRAY['canvas', '2d', 'circle', 'graphics', 'game-dev'],
  ARRAY['html']
) ON CONFLICT (slug) DO NOTHING;

-- ── 1b. Animated bouncing circle ─────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'canvas-bouncing-ball',
  'Animate a Bouncing Ball',
  E'Animate a circle that bounces off all four canvas edges.\n\n**Requirements:**\n- Circle starts somewhere on screen with a velocity vector `(vx, vy)`\n- On each frame: move by `(vx, vy)` and bounce (reverse velocity component) when hitting an edge\n- Use `requestAnimationFrame` for smooth animation\n- Clear the canvas each frame\n- Ball must have a visible trail **or** a solid colour — your choice\n\n**Bonus:** Add a gradient or glow to the ball.',
  'html_css', 'Easy', 'Game Dev', 80,
  $sc${"html": "<!DOCTYPE html>\n<html>\n<head>\n  <style>\n    * { margin: 0; padding: 0; }\n    body { background: #0A0906; overflow: hidden; }\n    canvas { display: block; }\n  </style>\n</head>\n<body>\n  <canvas id=\"c\"></canvas>\n  <script>\n    const canvas = document.getElementById('c');\n    const ctx = canvas.getContext('2d');\n    canvas.width  = window.innerWidth;\n    canvas.height = window.innerHeight;\n\n    const ball = {\n      x: canvas.width  / 2,\n      y: canvas.height / 2,\n      r: 30,\n      vx: 4,\n      vy: 3,\n    };\n\n    function update() {\n      // Move ball\n      // Bounce off edges\n      // Clear canvas\n      // Draw ball\n      requestAnimationFrame(update);\n    }\n\n    update();\n  </script>\n</body>\n</html>"}$sc$,
  ARRAY['Move: ball.x += ball.vx; ball.y += ball.vy', 'Bounce right wall: if (ball.x + ball.r > canvas.width) ball.vx *= -1', 'Clear each frame: ctx.clearRect(0, 0, canvas.width, canvas.height)', 'Or use ctx.fillRect with a semi-transparent fill for a trail effect'],
  ARRAY['canvas', 'animation', 'requestAnimationFrame', '2d', 'physics', 'game-dev'],
  ARRAY['html']
) ON CONFLICT (slug) DO NOTHING;

-- ── 1c. 2D particle system ────────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'canvas-particles',
  '2D Particle System',
  E'Build a simple particle system where particles **emit from the centre** of the canvas.\n\n**Requirements:**\n- At least **100 particles** alive at any time\n- Each particle has: position, velocity, lifetime, colour\n- Particles fade out as their lifetime decreases (reduce alpha)\n- Respawn particles when their lifetime expires\n- Smooth `requestAnimationFrame` loop\n\n**Bonus:** Vary particle speed, size, or colour based on emission angle.',
  'html_css', 'Medium', 'Game Dev', 120,
  $sc${"html": "<!DOCTYPE html>\n<html>\n<head>\n  <style>\n    * { margin: 0; padding: 0; }\n    body { background: #0A0906; overflow: hidden; }\n    canvas { display: block; }\n  </style>\n</head>\n<body>\n  <canvas id=\"c\"></canvas>\n  <script>\n    const canvas = document.getElementById('c');\n    const ctx    = canvas.getContext('2d');\n    canvas.width  = window.innerWidth;\n    canvas.height = window.innerHeight;\n\n    const PARTICLE_COUNT = 150;\n    const particles = [];\n\n    function createParticle() {\n      const angle = Math.random() * Math.PI * 2;\n      const speed = Math.random() * 3 + 1;\n      return {\n        x:        canvas.width  / 2,\n        y:        canvas.height / 2,\n        vx:       Math.cos(angle) * speed,\n        vy:       Math.sin(angle) * speed,\n        life:     1.0,         // 1 = full, 0 = dead\n        decay:    Math.random() * 0.01 + 0.005,\n        size:     Math.random() * 4 + 1,\n        hue:      Math.random() * 60 + 20,  // warm tones\n      };\n    }\n\n    // Initialise pool\n    for (let i = 0; i < PARTICLE_COUNT; i++) {\n      const p = createParticle();\n      p.life = Math.random(); // stagger initial lifetimes\n      particles.push(p);\n    }\n\n    function update() {\n      ctx.fillStyle = 'rgba(10,9,6,0.15)';\n      ctx.fillRect(0, 0, canvas.width, canvas.height);\n\n      for (const p of particles) {\n        // Update position, reduce life\n        // If dead, reset via createParticle()\n        // Draw with alpha = p.life\n      }\n\n      requestAnimationFrame(update);\n    }\n\n    update();\n  </script>\n</body>\n</html>"}$sc$,
  ARRAY['Move: p.x += p.vx; p.y += p.vy; p.life -= p.decay', 'Draw: ctx.globalAlpha = p.life before drawing', 'Reset: Object.assign(p, createParticle()) when p.life <= 0', 'Use hsl(p.hue, 100%, 60%) for colour'],
  ARRAY['canvas', 'particles', 'animation', '2d', 'game-dev', 'simulation'],
  ARRAY['html']
) ON CONFLICT (slug) DO NOTHING;


-- ══════════════════════════════════════════════════════════════════════════
-- TIER 2 — THREE.JS BASICS
-- ══════════════════════════════════════════════════════════════════════════

-- ── 2a. First Three.js scene ─────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'threejs-first-scene',
  'Three.js: Your First 3D Scene',
  E'Set up a minimal Three.js scene with a **rotating cube**.\n\n**Requirements:**\n- A `WebGLRenderer` that fills the window\n- A `PerspectiveCamera` positioned back on the Z axis\n- A `BoxGeometry` with a `MeshBasicMaterial` (no lighting needed yet)\n- The cube rotates on both X and Y axes each frame\n- `requestAnimationFrame` animation loop\n\nThis is the Three.js equivalent of "Hello World".',
  'html_css', 'Easy', 'Game Dev', 80,
  $sc${"html": "<!DOCTYPE html>\n<html>\n<head>\n  <style>* { margin:0; padding:0; } body { background:#000; overflow:hidden; }</style>\n</head>\n<body>\n  <script src=\"https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js\"></script>\n  <script>\n    // Scene\n    const scene    = new THREE.Scene();\n    const camera   = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);\n    const renderer = new THREE.WebGLRenderer({ antialias: true });\n    renderer.setSize(window.innerWidth, window.innerHeight);\n    document.body.appendChild(renderer.domElement);\n\n    // Cube\n    const geometry = new THREE.BoxGeometry();\n    const material = new THREE.MeshBasicMaterial({ color: 0xC9A84C, wireframe: false });\n    const cube     = new THREE.Mesh(geometry, material);\n    scene.add(cube);\n\n    camera.position.z = 5;\n\n    // Animation loop\n    function animate() {\n      requestAnimationFrame(animate);\n      // Rotate cube here\n      renderer.render(scene, camera);\n    }\n    animate();\n  </script>\n</body>\n</html>"}$sc$,
  ARRAY['cube.rotation.x += 0.01; cube.rotation.y += 0.01;', 'renderer.render(scene, camera) must be called every frame', 'camera.position.z = 5 moves the camera back so we can see the cube', 'THREE.BoxGeometry() creates a 1x1x1 cube by default'],
  ARRAY['threejs', '3d', 'webgl', 'scene', 'rotation', 'game-dev'],
  ARRAY['html']
) ON CONFLICT (slug) DO NOTHING;

-- ── 2b. Render a 3D sphere ────────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'threejs-sphere',
  'Three.js: Render a Lit 3D Sphere',
  E'Render a **shaded 3D sphere** with lighting so it actually looks 3D (not a flat disc).\n\n**Requirements:**\n- `SphereGeometry` with at least 32 width and height segments for smoothness\n- `MeshPhongMaterial` or `MeshStandardMaterial` (NOT MeshBasicMaterial — needs lighting)\n- At least one `PointLight` or `DirectionalLight` in the scene\n- An `AmbientLight` for fill\n- The sphere slowly rotates\n\n**The key insight:** Without lighting, a shaded material looks identical to a flat circle.',
  'html_css', 'Medium', 'Game Dev', 120,
  $sc${"html": "<!DOCTYPE html>\n<html>\n<head>\n  <style>* { margin:0; padding:0; } body { background:#0A0906; overflow:hidden; }</style>\n</head>\n<body>\n  <script src=\"https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js\"></script>\n  <script>\n    const scene    = new THREE.Scene();\n    const camera   = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 100);\n    const renderer = new THREE.WebGLRenderer({ antialias: true });\n    renderer.setSize(window.innerWidth, window.innerHeight);\n    renderer.setPixelRatio(window.devicePixelRatio);\n    document.body.appendChild(renderer.domElement);\n\n    camera.position.set(0, 0, 4);\n\n    // Create sphere\n    // geometry: THREE.SphereGeometry(radius, widthSegments, heightSegments)\n    // material: needs lighting to show 3D shape\n    // add lights\n\n    function animate() {\n      requestAnimationFrame(animate);\n      // rotate sphere\n      renderer.render(scene, camera);\n    }\n    animate();\n  </script>\n</body>\n</html>"}$sc$,
  ARRAY['new THREE.SphereGeometry(1, 32, 32) — radius 1, 32 segments each axis', 'MeshPhongMaterial({ color: 0x4488ff, shininess: 80 }) responds to light', 'new THREE.PointLight(0xffffff, 1) — position it at (5, 5, 5)', 'new THREE.AmbientLight(0x222222) gives fill light so the dark side isn''t pure black'],
  ARRAY['threejs', '3d', 'sphere', 'lighting', 'shading', 'game-dev', 'webgl'],
  ARRAY['html']
) ON CONFLICT (slug) DO NOTHING;

-- ── 2c. Solar system ─────────────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'threejs-solar-system',
  'Three.js: Mini Solar System',
  E'Build a simplified solar system with a **central star** and **at least two orbiting planets**.\n\n**Requirements:**\n- A large central sphere (the star) with an emissive/glowing material\n- Two smaller spheres orbiting at different radii and different speeds\n- Orbits achieved using a parent `Object3D` pivot that rotates, with the planet as a child offset on X\n- An `AmbientLight` plus a `PointLight` at the star position\n- Smooth animation loop\n\n**Key technique:** Parent–child transforms. Rotating the parent pivots the child around the origin.',
  'html_css', 'Medium', 'Game Dev', 150,
  $sc${"html": "<!DOCTYPE html>\n<html>\n<head>\n  <style>* { margin:0; padding:0; } body { background:#000; overflow:hidden; }</style>\n</head>\n<body>\n  <script src=\"https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js\"></script>\n  <script>\n    const scene    = new THREE.Scene();\n    const camera   = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 100);\n    const renderer = new THREE.WebGLRenderer({ antialias: true });\n    renderer.setSize(window.innerWidth, window.innerHeight);\n    document.body.appendChild(renderer.domElement);\n    camera.position.set(0, 12, 18);\n    camera.lookAt(0, 0, 0);\n\n    // Star (emissive so it glows without needing external light)\n    const starGeo = new THREE.SphereGeometry(1.5, 32, 32);\n    const starMat = new THREE.MeshStandardMaterial({ color: 0xffdd44, emissive: 0xffaa00, emissiveIntensity: 1 });\n    const star    = new THREE.Mesh(starGeo, starMat);\n    scene.add(star);\n\n    // Lights\n    scene.add(new THREE.AmbientLight(0x111122));\n    const sunLight = new THREE.PointLight(0xffeeaa, 2, 50);\n    scene.add(sunLight);\n\n    // TODO: Create two planet orbits using Object3D pivots\n    // const pivot1 = new THREE.Object3D();\n    // scene.add(pivot1);\n    // const planet1 = new THREE.Mesh(...);\n    // planet1.position.x = 4;  // orbital radius\n    // pivot1.add(planet1);\n\n    function animate() {\n      requestAnimationFrame(animate);\n      // pivot1.rotation.y += 0.01;\n      // pivot2.rotation.y += 0.006;\n      renderer.render(scene, camera);\n    }\n    animate();\n  </script>\n</body>\n</html>"}$sc$,
  ARRAY['Parent pivot technique: scene → pivot → planet offset on X', 'pivot.rotation.y += speed rotates the planet around the origin', 'Different orbital radii: planet1.position.x = 4; planet2.position.x = 7', 'camera.lookAt(0,0,0) points the camera at the star'],
  ARRAY['threejs', '3d', 'scene-graph', 'orbits', 'transforms', 'game-dev'],
  ARRAY['html']
) ON CONFLICT (slug) DO NOTHING;


-- ══════════════════════════════════════════════════════════════════════════
-- TIER 3 — CAMERAS, LIGHTING, INTERACTION
-- ══════════════════════════════════════════════════════════════════════════

-- ── 3a. Orbital camera ────────────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'threejs-orbit-camera',
  'Three.js: Build an Orbital Camera',
  E'Implement **orbital camera controls from scratch** — no OrbitControls library.\n\nThe user should be able to:\n- **Left-click + drag** to orbit (rotate around the target)\n- **Scroll wheel** to zoom in/out\n- The camera always looks at the origin `(0,0,0)`\n\n**How orbital cameras work:**\nStore the camera''s position in **spherical coordinates** `(radius, theta, phi)`. Mouse drag changes `theta` (horizontal) and `phi` (vertical). Scroll changes `radius`. Convert back to Cartesian for `camera.position` each frame.\n\n**Requirements:**\n- A `SphereGeometry` or other object to orbit around\n- Mouse drag orbits\n- Scroll wheel zooms\n- `camera.lookAt(0,0,0)` every frame\n- Clamp `phi` to avoid flipping over the poles',
  'html_css', 'Hard', 'Game Dev', 220,
  $sc${"html": "<!DOCTYPE html>\n<html>\n<head>\n  <style>* { margin:0; padding:0; } body { background:#0A0906; overflow:hidden; } canvas { display:block; }</style>\n</head>\n<body>\n  <script src=\"https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js\"></script>\n  <script>\n    const scene    = new THREE.Scene();\n    const camera   = new THREE.PerspectiveCamera(60, window.innerWidth/window.innerHeight, 0.1, 100);\n    const renderer = new THREE.WebGLRenderer({ antialias: true });\n    renderer.setSize(window.innerWidth, window.innerHeight);\n    document.body.appendChild(renderer.domElement);\n\n    // Something to orbit around\n    const geo = new THREE.IcosahedronGeometry(1, 2);\n    const mat = new THREE.MeshStandardMaterial({ color: 0xC9A84C, roughness: 0.4, metalness: 0.6 });\n    scene.add(new THREE.Mesh(geo, mat));\n    scene.add(new THREE.AmbientLight(0x333333));\n    const light = new THREE.DirectionalLight(0xffffff, 1);\n    light.position.set(5, 10, 5);\n    scene.add(light);\n\n    // Spherical camera state\n    let radius = 5;\n    let theta  = 0;               // horizontal angle (radians)\n    let phi    = Math.PI / 4;     // vertical angle (radians)\n\n    // Mouse state\n    let isDragging = false;\n    let lastX = 0, lastY = 0;\n\n    renderer.domElement.addEventListener('mousedown', e => {\n      isDragging = true;\n      lastX = e.clientX;\n      lastY = e.clientY;\n    });\n    window.addEventListener('mouseup',   () => isDragging = false);\n    window.addEventListener('mousemove', e => {\n      if (!isDragging) return;\n      const dx = e.clientX - lastX;\n      const dy = e.clientY - lastY;\n      lastX = e.clientX;\n      lastY = e.clientY;\n      // TODO: update theta and phi from dx/dy\n    });\n    renderer.domElement.addEventListener('wheel', e => {\n      // TODO: update radius from e.deltaY\n    });\n\n    function updateCamera() {\n      // Convert spherical → Cartesian and set camera.position\n      // camera.position.x = radius * Math.sin(phi) * Math.sin(theta);\n      // camera.position.y = radius * Math.cos(phi);\n      // camera.position.z = radius * Math.sin(phi) * Math.cos(theta);\n      camera.lookAt(0, 0, 0);\n    }\n\n    function animate() {\n      requestAnimationFrame(animate);\n      updateCamera();\n      renderer.render(scene, camera);\n    }\n    animate();\n  </script>\n</body>\n</html>"}$sc$,
  ARRAY['theta += dx * 0.005; phi -= dy * 0.005 (note: dy is inverted)', 'Clamp phi: phi = Math.max(0.1, Math.min(Math.PI - 0.1, phi))', 'Spherical to Cartesian: x = r*sin(phi)*sin(theta), y = r*cos(phi), z = r*sin(phi)*cos(theta)', 'Zoom: radius += e.deltaY * 0.01; radius = Math.max(2, Math.min(20, radius))'],
  ARRAY['threejs', 'camera', 'orbital-controls', '3d', 'spherical-coordinates', 'interaction', 'game-dev'],
  ARRAY['html']
) ON CONFLICT (slug) DO NOTHING;

-- ── 3b. First-person camera ───────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'threejs-fps-camera',
  'Three.js: First-Person Camera',
  E'Build a **first-person camera** that the user controls with keyboard and mouse.\n\n**Controls:**\n- `W/A/S/D` — move forward/left/back/right\n- **Mouse drag** — look around (yaw and pitch)\n- Movement is always relative to the direction the camera faces\n\n**Requirements:**\n- A floor plane and a few box obstacles to navigate around\n- Mouse look changes yaw (Y-axis) and pitch (X-axis)\n- Clamp pitch to ±85° to prevent flipping\n- Movement uses the camera''s forward vector projected onto the XZ plane\n\n**Key math:** Extract the camera''s forward direction from its quaternion or use a `yaw` + `pitch` Euler approach.',
  'html_css', 'Hard', 'Game Dev', 250,
  $sc${"html": "<!DOCTYPE html>\n<html>\n<head>\n  <style>* { margin:0; padding:0; } body { background:#0A0906; overflow:hidden; } canvas { cursor:crosshair; }</style>\n</head>\n<body>\n  <script src=\"https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js\"></script>\n  <script>\n    const scene    = new THREE.Scene();\n    scene.background = new THREE.Color(0x111111);\n    scene.fog        = new THREE.Fog(0x111111, 10, 50);\n    const camera   = new THREE.PerspectiveCamera(75, window.innerWidth/window.innerHeight, 0.1, 100);\n    const renderer = new THREE.WebGLRenderer({ antialias: true });\n    renderer.setSize(window.innerWidth, window.innerHeight);\n    renderer.shadowMap.enabled = true;\n    document.body.appendChild(renderer.domElement);\n\n    // Floor\n    const floor = new THREE.Mesh(\n      new THREE.PlaneGeometry(40, 40),\n      new THREE.MeshStandardMaterial({ color: 0x222222 })\n    );\n    floor.rotation.x = -Math.PI / 2;\n    floor.receiveShadow = true;\n    scene.add(floor);\n\n    // A few boxes\n    const boxMat = new THREE.MeshStandardMaterial({ color: 0xC9A84C });\n    [[-3,0],[3,0],[0,4],[-4,5],[5,-3]].forEach(([x,z]) => {\n      const b = new THREE.Mesh(new THREE.BoxGeometry(1, 2, 1), boxMat);\n      b.position.set(x, 1, z);\n      b.castShadow = true;\n      scene.add(b);\n    });\n\n    // Light\n    scene.add(new THREE.AmbientLight(0x404040));\n    const dir = new THREE.DirectionalLight(0xffffff, 0.8);\n    dir.position.set(10, 20, 10);\n    dir.castShadow = true;\n    scene.add(dir);\n\n    camera.position.set(0, 1.7, 0);\n\n    // Camera angles\n    let yaw   = 0;    // left/right\n    let pitch = 0;    // up/down\n\n    // Mouse look\n    let isDragging = false, lastX = 0, lastY = 0;\n    renderer.domElement.addEventListener('mousedown', e => { isDragging = true; lastX = e.clientX; lastY = e.clientY; });\n    window.addEventListener('mouseup', () => isDragging = false);\n    window.addEventListener('mousemove', e => {\n      if (!isDragging) return;\n      // TODO: update yaw and pitch\n      lastX = e.clientX;\n      lastY = e.clientY;\n    });\n\n    // Keys\n    const keys = {};\n    window.addEventListener('keydown', e => keys[e.key.toLowerCase()] = true);\n    window.addEventListener('keyup',   e => keys[e.key.toLowerCase()] = false);\n\n    const SPEED = 0.08;\n    function updateCamera() {\n      // Apply yaw/pitch to camera\n      camera.rotation.order = 'YXZ';\n      camera.rotation.y = yaw;\n      camera.rotation.x = pitch;\n\n      // Movement — extract forward/right from camera\n      if (keys['w'] || keys['a'] || keys['s'] || keys['d']) {\n        const forward = new THREE.Vector3();\n        camera.getWorldDirection(forward);\n        forward.y = 0;\n        forward.normalize();\n        const right = new THREE.Vector3();\n        right.crossVectors(forward, new THREE.Vector3(0,1,0));\n        // TODO: move camera based on keys\n      }\n    }\n\n    function animate() {\n      requestAnimationFrame(animate);\n      updateCamera();\n      renderer.render(scene, camera);\n    }\n    animate();\n  </script>\n</body>\n</html>"}$sc$,
  ARRAY['camera.rotation.order = ''YXZ'' is critical for FPS look-around', 'yaw -= dx * 0.003; pitch -= dy * 0.003 (subtract dy for natural feel)', 'Clamp pitch: pitch = Math.max(-Math.PI*0.47, Math.min(Math.PI*0.47, pitch))', 'Forward movement: camera.position.addScaledVector(forward, SPEED)', 'Strafe: camera.position.addScaledVector(right, SPEED)'],
  ARRAY['threejs', 'camera', 'fps', 'first-person', 'movement', '3d', 'game-dev'],
  ARRAY['html']
) ON CONFLICT (slug) DO NOTHING;

-- ── 3c. Shadow mapping ────────────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'threejs-shadows',
  'Three.js: Shadow Mapping',
  E'Enable **real-time shadow mapping** in a Three.js scene.\n\n**Requirements:**\n- `renderer.shadowMap.enabled = true`\n- A `DirectionalLight` with `castShadow = true`\n- At least two objects: one that **casts** shadows, one that **receives** them (a floor plane)\n- `PCFSoftShadowMap` for smoother shadow edges\n- Correct shadow camera frustum (shadows cover the scene)\n- The shadow-casting object rotates or moves so the shadow visibly animates\n\n**Common mistake:** Forgetting to set both `castShadow` on the mesh AND `receiveShadow` on the floor.',
  'html_css', 'Hard', 'Game Dev', 200,
  $sc${"html": "<!DOCTYPE html>\n<html>\n<head>\n  <style>* { margin:0; padding:0; } body { background:#111; overflow:hidden; }</style>\n</head>\n<body>\n  <script src=\"https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js\"></script>\n  <script>\n    const scene    = new THREE.Scene();\n    const camera   = new THREE.PerspectiveCamera(60, window.innerWidth/window.innerHeight, 0.1, 100);\n    const renderer = new THREE.WebGLRenderer({ antialias: true });\n    renderer.setSize(window.innerWidth, window.innerHeight);\n    // TODO: enable shadow map and set type to PCFSoftShadowMap\n    document.body.appendChild(renderer.domElement);\n\n    camera.position.set(0, 6, 10);\n    camera.lookAt(0, 0, 0);\n\n    // Directional light\n    const dirLight = new THREE.DirectionalLight(0xffffff, 1);\n    dirLight.position.set(5, 10, 5);\n    // TODO: enable shadow casting on the light\n    // TODO: set shadow camera bounds\n    scene.add(dirLight);\n    scene.add(new THREE.AmbientLight(0x303030));\n\n    // Floor\n    const floor = new THREE.Mesh(\n      new THREE.PlaneGeometry(20, 20),\n      new THREE.MeshStandardMaterial({ color: 0x333333 })\n    );\n    floor.rotation.x = -Math.PI / 2;\n    // TODO: floor should receive shadows\n    scene.add(floor);\n\n    // Floating box\n    const box = new THREE.Mesh(\n      new THREE.BoxGeometry(2, 2, 2),\n      new THREE.MeshStandardMaterial({ color: 0xC9A84C })\n    );\n    box.position.y = 2;\n    // TODO: box should cast shadows\n    scene.add(box);\n\n    function animate() {\n      requestAnimationFrame(animate);\n      box.rotation.y += 0.01;\n      box.rotation.x += 0.005;\n      renderer.render(scene, camera);\n    }\n    animate();\n  </script>\n</body>\n</html>"}$sc$,
  ARRAY['renderer.shadowMap.enabled = true; renderer.shadowMap.type = THREE.PCFSoftShadowMap;', 'dirLight.castShadow = true;', 'floor.receiveShadow = true; box.castShadow = true;', 'Shadow camera frustum: dirLight.shadow.camera.near = 0.1; .far = 50; .left = -10; .right = 10; .top = 10; .bottom = -10;'],
  ARRAY['threejs', 'shadows', 'shadow-mapping', 'lighting', '3d', 'game-dev', 'rendering'],
  ARRAY['html']
) ON CONFLICT (slug) DO NOTHING;


-- ══════════════════════════════════════════════════════════════════════════
-- TIER 4 — SHADERS & ADVANCED RENDERING
-- ══════════════════════════════════════════════════════════════════════════

-- ── 4a. Custom shader material ────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'threejs-shader-material',
  'Three.js: Write a Custom GLSL Shader',
  E'Replace Three.js''s built-in materials with a **custom `ShaderMaterial`** using raw GLSL.\n\nYour shader must:\n1. In the **vertex shader**: pass the world-space normal to the fragment shader as a `varying`\n2. In the **fragment shader**: colour the surface based on the normal direction — `r = abs(normal.x)`, `g = abs(normal.y)`, `b = abs(normal.z)` — producing a rainbow-like normal visualisation\n3. Apply this to a `SphereGeometry` that slowly rotates\n\n**This is the gateway to custom rendering.** Understanding uniforms, varyings, and the GLSL pipeline unlocks everything from water to cel-shading to procedural planets.',
  'html_css', 'Expert', 'Game Dev', 300,
  $sc${"html": "<!DOCTYPE html>\n<html>\n<head>\n  <style>* { margin:0; padding:0; } body { background:#0A0906; overflow:hidden; }</style>\n</head>\n<body>\n  <script src=\"https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js\"></script>\n  <script>\n    const scene    = new THREE.Scene();\n    const camera   = new THREE.PerspectiveCamera(60, window.innerWidth/window.innerHeight, 0.1, 100);\n    const renderer = new THREE.WebGLRenderer({ antialias: true });\n    renderer.setSize(window.innerWidth, window.innerHeight);\n    document.body.appendChild(renderer.domElement);\n    camera.position.z = 3;\n\n    const vertexShader = `\n      varying vec3 vNormal;\n      void main() {\n        // TODO: pass the normal to the fragment shader\n        // vNormal = ...\n        gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);\n      }\n    `;\n\n    const fragmentShader = `\n      varying vec3 vNormal;\n      void main() {\n        // TODO: colour based on abs(normal) components\n        // gl_FragColor = vec4(...);\n      }\n    `;\n\n    const material = new THREE.ShaderMaterial({\n      vertexShader,\n      fragmentShader,\n    });\n\n    const sphere = new THREE.Mesh(\n      new THREE.SphereGeometry(1, 64, 64),\n      material\n    );\n    scene.add(sphere);\n\n    function animate() {\n      requestAnimationFrame(animate);\n      sphere.rotation.y += 0.005;\n      renderer.render(scene, camera);\n    }\n    animate();\n  </script>\n</body>\n</html>"}$sc$,
  ARRAY['Vertex: vNormal = normalize(normalMatrix * normal);', 'Fragment: gl_FragColor = vec4(abs(vNormal), 1.0);', 'normalMatrix transforms normals to view space — built in to Three.js ShaderMaterial', 'Varyings must be declared in BOTH vertex and fragment shaders'],
  ARRAY['threejs', 'glsl', 'shader', 'shader-material', 'normals', 'expert', 'game-dev', 'rendering'],
  ARRAY['html']
) ON CONFLICT (slug) DO NOTHING;

-- ── 4b. Procedural noise terrain ─────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'threejs-terrain',
  'Three.js: Procedural Terrain with Noise',
  E'Generate a **procedural terrain mesh** by displacing the vertices of a `PlaneGeometry` using a noise function.\n\n**Requirements:**\n- A `PlaneGeometry` with at least **128×128** segments\n- Displace each vertex Y position using a 2D noise function (implement simple value noise or use the provided helper)\n- Colour vertices by height (low = dark blue, mid = green, high = white/grey)\n- Use `vertexColors: true` on the material\n- The terrain gently animates (noise offset scrolls over time, or camera orbits)\n- `geometry.computeVertexNormals()` after displacement for correct lighting\n\n**Noise helper provided** — focus on the vertex displacement and colour logic.',
  'html_css', 'Expert', 'Game Dev', 320,
  $sc${"html": "<!DOCTYPE html>\n<html>\n<head>\n  <style>* { margin:0; padding:0; } body { background:#000; overflow:hidden; }</style>\n</head>\n<body>\n  <script src=\"https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js\"></script>\n  <script>\n    // Simple value noise — returns a value roughly in [-1, 1]\n    function hash(n) { return (Math.sin(n) * 43758.5453123) % 1; }\n    function noise2d(x, z) {\n      const ix = Math.floor(x), iz = Math.floor(z);\n      const fx = x - ix,       fz = z - iz;\n      const ux = fx*fx*(3-2*fx), uz = fz*fz*(3-2*fz);\n      const a = hash(ix     + iz     * 57);\n      const b = hash(ix + 1 + iz     * 57);\n      const c = hash(ix     + (iz+1) * 57);\n      const d = hash(ix + 1 + (iz+1) * 57);\n      return a + (b-a)*ux + (c-a)*uz + (d-a+a-b-c+b)*ux*uz;\n    }\n    // Fractal noise — layers of noise at different scales\n    function fbm(x, z, octaves = 5) {\n      let v = 0, amp = 0.5, freq = 1, max = 0;\n      for (let i = 0; i < octaves; i++) {\n        v   += noise2d(x * freq, z * freq) * amp;\n        max += amp;\n        amp  *= 0.5;\n        freq *= 2.1;\n      }\n      return v / max;\n    }\n\n    const scene    = new THREE.Scene();\n    const camera   = new THREE.PerspectiveCamera(60, window.innerWidth/window.innerHeight, 0.1, 500);\n    const renderer = new THREE.WebGLRenderer({ antialias: true });\n    renderer.setSize(window.innerWidth, window.innerHeight);\n    document.body.appendChild(renderer.domElement);\n    camera.position.set(0, 30, 60);\n    camera.lookAt(0, 0, 0);\n    scene.add(new THREE.AmbientLight(0x445566));\n    const sun = new THREE.DirectionalLight(0xfff0cc, 1.2);\n    sun.position.set(50, 80, 30);\n    scene.add(sun);\n\n    const SEG   = 128;\n    const SIZE  = 80;\n    const HEIGHT = 12;\n    const geo   = new THREE.PlaneGeometry(SIZE, SIZE, SEG, SEG);\n    geo.rotateX(-Math.PI / 2);\n\n    const pos    = geo.attributes.position;\n    const colors = [];\n\n    for (let i = 0; i < pos.count; i++) {\n      const x = pos.getX(i);\n      const z = pos.getZ(i);\n\n      // TODO: sample fbm noise and set vertex Y\n      // const h = fbm(x / 20, z / 20) * HEIGHT;\n      // pos.setY(i, h);\n\n      // TODO: set vertex colour based on height\n      // low (h < 0.5)  → deep blue\n      // mid (h < 4)    → green/brown\n      // high (h >= 4)  → grey/white\n      colors.push(1, 1, 1); // placeholder: all white\n    }\n\n    geo.setAttribute('color', new THREE.Float32BufferAttribute(colors, 3));\n    geo.computeVertexNormals();\n\n    const mat  = new THREE.MeshStandardMaterial({ vertexColors: true, flatShading: false });\n    const mesh = new THREE.Mesh(geo, mat);\n    scene.add(mesh);\n\n    let t = 0;\n    function animate() {\n      requestAnimationFrame(animate);\n      // Optional: animate terrain by scrolling noise offset\n      renderer.render(scene, camera);\n    }\n    animate();\n  </script>\n</body>\n</html>"}$sc$,
  ARRAY['Sample: const h = fbm(x / 20 + t, z / 20) * HEIGHT; pos.setY(i, h);', 'After modifying positions: pos.needsUpdate = true; geo.computeVertexNormals();', 'Colour by height: if h < 0 → (0.1, 0.2, 0.5) blue, h < 4 → (0.2, 0.5, 0.2) green, else → (0.7, 0.7, 0.7)', 'For animation: increment t each frame and re-run the displacement loop'],
  ARRAY['threejs', 'procedural', 'terrain', 'noise', 'vertex-shader', 'fbm', 'expert', 'game-dev'],
  ARRAY['html']
) ON CONFLICT (slug) DO NOTHING;

-- ── 4c. Raycasting / click to select ─────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'threejs-raycasting',
  'Three.js: Raycasting — Click to Select',
  E'Implement **mouse picking** using Three.js raycasting — clicking an object highlights it.\n\n**Requirements:**\n- At least **5 objects** scattered in the scene\n- On **mouse click**: cast a ray from the camera through the click position into the scene\n- The **first hit object** changes colour (highlight)\n- Previously selected object reverts to its original colour\n- A text label shows the name of the selected object (use a `<div>` overlay, not 3D text)\n\n**This is fundamental to any interactive 3D app** — game engines, CAD tools, and editors all use raycasting for selection.',
  'html_css', 'Hard', 'Game Dev', 230,
  $sc${"html": "<!DOCTYPE html>\n<html>\n<head>\n  <style>\n    * { margin:0; padding:0; }\n    body { background:#0A0906; overflow:hidden; }\n    #label {\n      position: absolute; top: 16px; left: 50%; transform: translateX(-50%);\n      color: #C9A84C; font-family: monospace; font-size: 14px;\n      pointer-events: none; letter-spacing: 0.1em;\n    }\n  </style>\n</head>\n<body>\n  <div id=\"label\">Click an object</div>\n  <script src=\"https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js\"></script>\n  <script>\n    const scene    = new THREE.Scene();\n    const camera   = new THREE.PerspectiveCamera(60, window.innerWidth/window.innerHeight, 0.1, 100);\n    const renderer = new THREE.WebGLRenderer({ antialias: true });\n    renderer.setSize(window.innerWidth, window.innerHeight);\n    document.body.appendChild(renderer.domElement);\n    camera.position.set(0, 3, 10);\n    camera.lookAt(0, 0, 0);\n    scene.add(new THREE.AmbientLight(0x444444));\n    const light = new THREE.DirectionalLight(0xffffff, 1);\n    light.position.set(5, 10, 5);\n    scene.add(light);\n\n    // Create objects\n    const shapes = [\n      { geo: new THREE.BoxGeometry(),              name: 'Cube',        pos: [-4,0,0],  color: 0x4488ff },\n      { geo: new THREE.SphereGeometry(0.7,32,32),  name: 'Sphere',      pos: [-2,0,0],  color: 0xff4444 },\n      { geo: new THREE.ConeGeometry(0.7,1.5,32),   name: 'Cone',        pos: [0,0,0],   color: 0x44cc44 },\n      { geo: new THREE.TorusGeometry(0.6,0.2,16,50),name:'Torus',       pos: [2,0,0],   color: 0xcc44cc },\n      { geo: new THREE.OctahedronGeometry(0.8),     name: 'Octahedron',  pos: [4,0,0],   color: 0xffaa22 },\n    ];\n\n    const meshes = shapes.map(s => {\n      const m = new THREE.Mesh(s.geo, new THREE.MeshStandardMaterial({ color: s.color }));\n      m.position.set(...s.pos);\n      m.userData.name          = s.name;\n      m.userData.originalColor = s.color;\n      scene.add(m);\n      return m;\n    });\n\n    const raycaster = new THREE.Raycaster();\n    const mouse     = new THREE.Vector2();\n    let   selected  = null;\n\n    renderer.domElement.addEventListener('click', e => {\n      // TODO: convert mouse coords to NDC (-1 to +1)\n      // mouse.x = (e.clientX / window.innerWidth)  * 2 - 1;\n      // mouse.y = -(e.clientY / window.innerHeight) * 2 + 1;\n\n      // TODO: update raycaster and find intersections\n      // raycaster.setFromCamera(mouse, camera);\n      // const hits = raycaster.intersectObjects(meshes);\n\n      // TODO: highlight first hit, revert previous\n    });\n\n    function animate() {\n      requestAnimationFrame(animate);\n      meshes.forEach((m, i) => m.rotation.y += 0.005 * (i % 2 ? 1 : -1));\n      renderer.render(scene, camera);\n    }\n    animate();\n  </script>\n</body>\n</html>"}$sc$,
  ARRAY['NDC: mouse.x = (e.clientX / window.innerWidth) * 2 - 1; mouse.y = -(e.clientY / window.innerHeight) * 2 + 1;', 'raycaster.setFromCamera(mouse, camera); const hits = raycaster.intersectObjects(meshes);', 'hits[0].object gives you the first hit mesh', 'Revert: if (selected) selected.material.color.setHex(selected.userData.originalColor);', 'Highlight: hits[0].object.material.color.setHex(0xffffff);'],
  ARRAY['threejs', 'raycasting', 'picking', 'mouse', 'interaction', '3d', 'game-dev'],
  ARRAY['html']
) ON CONFLICT (slug) DO NOTHING;

-- ── Update category for all rendering problems ────────────────────────────
UPDATE problems
SET category = 'Game Dev'
WHERE slug IN (
  'canvas-circle', 'canvas-bouncing-ball', 'canvas-particles',
  'threejs-first-scene', 'threejs-sphere', 'threejs-solar-system',
  'threejs-orbit-camera', 'threejs-fps-camera', 'threejs-shadows',
  'threejs-shader-material', 'threejs-terrain', 'threejs-raycasting'
);