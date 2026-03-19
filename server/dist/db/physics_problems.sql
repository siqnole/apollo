-- ── Physics Problems: Kinematics, Dynamics & Circular Motion ───────────────
-- Run: psql -U postgres -d apollo -h localhost -f physics_problems.sql
-- Requires LaTeX rendering (KaTeX) in the frontend for equations.

-- ─────────────────────────────────────────────────────────────────────────
-- KINEMATICS: Velocity and Displacement
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'kinematics-constant-velocity',
  'Constant Velocity: Displacement Calculation',
  E'An object moves at constant velocity. The relationship between displacement, velocity, and time is:\n\n$$s = v \\cdot t$$\n\nwhere:\n- $s$ = displacement (meters)\n- $v$ = velocity (m/s)\n- $t$ = time (seconds)\n\n**Problem:** A car travels at 25 m/s for 8 seconds. What is the displacement?\n\nProvide your answer in meters.',
  'fill_blank', 'Easy', 'Physics', 75,
  ARRAY['Use the formula s = v × t directly', 's = 25 × 8'],
  ARRAY['kinematics', 'velocity', 'displacement', 'motion', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='kinematics-constant-velocity'), '', '200', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'kinematics-acceleration-time',
  'Uniform Acceleration: Final Velocity',
  E'For motion with constant acceleration, the kinematic equation is:\n\n$$v_f = v_i + a \\cdot t$$\n\nwhere:\n- $v_f$ = final velocity (m/s)\n- $v_i$ = initial velocity (m/s)\n- $a$ = acceleration (m/s²)\n- $t$ = time (seconds)\n\n**Problem:** A bicycle starts from rest ($v_i = 0$) and accelerates uniformly at $a = 2.5$ m/s² for 6 seconds. What is the final velocity?\n\nProvide your answer in m/s.',
  'fill_blank', 'Easy', 'Physics', 85,
  ARRAY['Starting from rest means v_i = 0', 'v_f = 0 + 2.5 × 6'],
  ARRAY['kinematics', 'acceleration', 'velocity', 'motion', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='kinematics-acceleration-time'), '', '15', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'kinematics-displacement-acceleration',
  'Displacement with Uniform Acceleration',
  E'The kinematic equation relating displacement, initial velocity, acceleration, and time is:\n\n$$s = v_i \\cdot t + \\frac{1}{2} a \\cdot t^2$$\n\nwhere:\n- $s$ = displacement (meters)\n- $v_i$ = initial velocity (m/s)\n- $a$ = acceleration (m/s²)\n- $t$ = time (seconds)\n\n**Problem:** An object starts with initial velocity $v_i = 10$ m/s and accelerates at $a = 3$ m/s² for 4 seconds. What is the displacement?\n\nProvide your answer in meters.',
  'fill_blank', 'Medium', 'Physics', 100,
  ARRAY['Substitute into the equation: s = 10(4) + 0.5(3)(4²)', 's = 40 + 0.5(3)(16) = 40 + 24'],
  ARRAY['kinematics', 'displacement', 'acceleration', 'motion', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='kinematics-displacement-acceleration'), '', '64', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- KINEMATICS: Velocity-Displacement Relationship
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'kinematics-velocity-displacement',
  'Velocity from Displacement and Acceleration',
  E'When time is unknown, we can relate velocity and displacement using:\n\n$$v_f^2 = v_i^2 + 2 a s$$\n\nwhere:\n- $v_f$ = final velocity (m/s)\n- $v_i$ = initial velocity (m/s)\n- $a$ = acceleration (m/s²)\n- $s$ = displacement (meters)\n\n**Problem:** A car at rest ($v_i = 0$) accelerates at $a = 4$ m/s² over a distance of 50 meters. What is the final velocity?\n\nRound to 1 decimal place.',
  'fill_blank', 'Medium', 'Physics', 110,
  ARRAY['v_f² = 0 + 2(4)(50)', 'v_f² = 400', 'Take the square root: v_f = √400'],
  ARRAY['kinematics', 'velocity', 'displacement', 'acceleration', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='kinematics-velocity-displacement'), '', '20.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- DYNAMICS: Newton's Laws and Forces
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'dynamics-newtons-second-law',
  'Newton''s Second Law: Force and Acceleration',
  E'Newton''s Second Law states:\n\n$$F = m \\cdot a$$\n\nwhere:\n- $F$ = net force (Newtons)\n- $m$ = mass (kg)\n- $a$ = acceleration (m/s²)\n\n**Problem:** A 12 kg object accelerates at 3.5 m/s². What is the net force acting on it?\n\nProvide your answer in Newtons.',
  'fill_blank', 'Easy', 'Physics', 90,
  ARRAY['Use F = m × a directly', 'F = 12 × 3.5'],
  ARRAY['dynamics', 'force', 'newtons-law', 'acceleration', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='dynamics-newtons-second-law'), '', '42', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'dynamics-friction-force',
  'Friction and Net Force',
  E'When friction is involved, the net force is:\n\n$$F_{{net}} = F_{{applied}} - F_{{friction}}$$\n\nFriction is calculated as:\n\n$$F_{{friction}} = \\mu \\cdot F_{{normal}}$$\n\nwhere:\n- $\\mu$ = coefficient of kinetic friction (dimensionless)\n- $F_{{normal}}$ = normal force (N)\n\n**Problem:** A 50 kg box is dragged across a horizontal surface with an applied force of 150 N. The coefficient of kinetic friction is $\\mu_k = 0.2$. Assume $g = 10$ m/s².\n\nWhat is the net force on the box?\n\nProvide your answer in Newtons.',
  'fill_blank', 'Medium', 'Physics', 120,
  ARRAY['F_normal = m × g = 50 × 10 = 500 N', 'F_friction = 0.2 × 500 = 100 N', 'F_net = 150 - 100 = 50 N'],
  ARRAY['dynamics', 'friction', 'force', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='dynamics-friction-force'), '', '50', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'dynamics-tension-pulley',
  'Tension in Pulley System',
  E'In an ideal pulley system with two masses, if we ignore friction:\n\n$$a = \\frac{(m_1 - m_2) g}{m_1 + m_2}$$\n\n$$T = \\frac{2 m_1 m_2 g}{m_1 + m_2}$$\n\nwhere:\n- $m_1$ = heavier mass (kg)\n- $m_2$ = lighter mass (kg)\n- $g$ = gravitational acceleration (9.8 m/s²)\n- $T$ = tension in the string (N)\n\n**Problem:** In an Atwood machine, $m_1 = 8$ kg and $m_2 = 3$ kg. Using $g = 10$ m/s², what is the tension in the string?\n\nRound to 1 decimal place.',
  'fill_blank', 'Hard', 'Physics', 150,
  ARRAY['T = 2(8)(3)(10) / (8 + 3)', 'T = 480 / 11'],
  ARRAY['dynamics', 'tension', 'pulley', 'atwood-machine', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='dynamics-tension-pulley'), '', '43.6', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- CIRCULAR MOTION: Centripetal Force and Acceleration
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'circular-centripetal-acceleration',
  'Centripetal Acceleration',
  E'An object moving in a circle at constant speed experiences centripetal acceleration:\n\n$$a_c = \\frac{v^2}{r}$$\n\nalternatively:\n\n$$a_c = \\omega^2 \\cdot r$$\n\nwhere:\n- $a_c$ = centripetal acceleration (m/s²)\n- $v$ = speed (m/s)\n- $r$ = radius of circular path (meters)\n- $\\omega$ = angular velocity (rad/s)\n\n**Problem:** A car travels at 20 m/s around a circular track with radius 50 meters. What is the centripetal acceleration?\n\nRound to 1 decimal place.',
  'fill_blank', 'Medium', 'Physics', 110,
  ARRAY['Use a_c = v² / r', 'a_c = (20)² / 50', 'a_c = 400 / 50'],
  ARRAY['circular-motion', 'centripetal-acceleration', 'velocity', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='circular-centripetal-acceleration'), '', '8.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'circular-centripetal-force',
  'Centripetal Force: Circular Motion',
  E'An object moving in a circle requires a centripetal force directed toward the center:\n\n$$F_c = m \\cdot a_c = \\frac{m v^2}{r}$$\n\nwhere:\n- $F_c$ = centripetal force (N)\n- $m$ = mass (kg)\n- $v$ = speed (m/s)\n- $r$ = radius (meters)\n\n**Problem:** A 1.5 kg ball is attached to a string and swung in a horizontal circle with radius 0.8 meters at speed 4 m/s. What centripetal force is required to keep it in circular motion?\n\nRound to 1 decimal place.',
  'fill_blank', 'Medium', 'Physics', 120,
  ARRAY['F_c = (1.5 × 4²) / 0.8', 'F_c = (1.5 × 16) / 0.8', 'F_c = 24 / 0.8'],
  ARRAY['circular-motion', 'centripetal-force', 'dynamics', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='circular-centripetal-force'), '', '30.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'circular-motion-banking',
  'Banking Angle and Circular Motion',
  E'On a banked circular track at angle $\\theta$, the relationship between speed, radius, and angle is:\n\n$$\\tan(\\theta) = \\frac{v^2}{r \\cdot g}$$\n\nFor no friction, an object can travel safely at a specific "design speed".\n\n**Problem:** A circular racetrack is banked at $\\theta = 20°$ with radius 400 meters. Using $g = 10$ m/s², what is the design speed (the speed at which an object needs no friction to stay in the circular path)?\n\nRound to 1 decimal place. Hint: $\\tan(20°) \\approx 0.364$',
  'fill_blank', 'Hard', 'Physics', 140,
  ARRAY['tan(θ) = v² / (r × g)', '0.364 = v² / (400 × 10)', 'v² = 0.364 × 4000', 'v = √1456'],
  ARRAY['circular-motion', 'banking', 'speed', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='circular-motion-banking'), '', '38.2', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- CIRCULAR MOTION: Angular Velocity and Period
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'circular-angular-velocity',
  'Angular Velocity and Linear Speed',
  E'Angular velocity relates to linear speed through the radius:\n\n$$v = \\omega \\cdot r$$\n\nor equivalently:\n\n$$\\omega = \\frac{2 \\pi}{T}$$\n\nwhere:\n- $\\omega$ = angular velocity (rad/s)\n- $v$ = linear speed (m/s)\n- $r$ = radius (meters)\n- $T$ = period (seconds)\n\n**Problem:** A point on the rim of a disk rotates with angular velocity $\\omega = 5$ rad/s. If the radius is 0.4 meters, what is the linear speed of the point?\n\nRound to 2 decimal places.',
  'fill_blank', 'Easy', 'Physics', 100,
  ARRAY['Use v = ω × r', 'v = 5 × 0.4'],
  ARRAY['circular-motion', 'angular-velocity', 'linear-speed', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='circular-angular-velocity'), '', '2.00', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'circular-period-frequency',
  'Period and Frequency in Circular Motion',
  E'Period and frequency are related by:\n\n$$T = \\frac{1}{f}$$\n\nand angular velocity is:\n\n$$\\omega = 2 \\pi f = \\frac{2 \\pi}{T}$$\n\nwhere:\n- $T$ = period (seconds per revolution)\n- $f$ = frequency (revolutions per second or Hz)\n- $\\omega$ = angular velocity (rad/s)\n\n**Problem:** A spinning wheel completes 120 revolutions per minute (RPM). What is the period (time for one complete revolution) in seconds?\n\nRound to 3 decimal places.',
  'fill_blank', 'Easy', 'Physics', 95,
  ARRAY['Convert RPM to revolutions per second: 120/60 = 2 rev/s', 'f = 2 Hz', 'T = 1/f = 1/2'],
  ARRAY['circular-motion', 'period', 'frequency', 'rotation', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='circular-period-frequency'), '', '0.500', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- ENERGY & WORK: Kinetic and Potential Energy
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'energy-kinetic',
  'Kinetic Energy',
  E'Kinetic energy is the energy of motion:\n\n$$KE = \\frac{1}{2} m v^2$$\n\nwhere:\n- $KE$ = kinetic energy (Joules)\n- $m$ = mass (kg)\n- $v$ = velocity (m/s)\n\n**Problem:** A 1200 kg car travels at 15 m/s. What is its kinetic energy?\n\nProvide your answer in Joules.',
  'fill_blank', 'Easy', 'Physics', 100,
  ARRAY['Use KE = 0.5 × m × v²', 'KE = 0.5 × 1200 × (15)²', 'KE = 600 × 225'],
  ARRAY['energy', 'kinetic', 'motion', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='energy-kinetic'), '', '135000', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'energy-potential',
  'Gravitational Potential Energy',
  E'Gravitational potential energy is the energy due to height:\n\n$$PE = m \\cdot g \\cdot h$$\n\nwhere:\n- $PE$ = potential energy (Joules)\n- $m$ = mass (kg)\n- $g$ = gravitational acceleration (9.8 m/s²)\n- $h$ = height above reference level (meters)\n\n**Problem:** A 5 kg object is lifted to a height of 8 meters. Using $g = 10$ m/s², what is its gravitational potential energy relative to the ground?\n\nProvide your answer in Joules.',
  'fill_blank', 'Easy', 'Physics', 100,
  ARRAY['Use PE = m × g × h', 'PE = 5 × 10 × 8'],
  ARRAY['energy', 'potential', 'height', 'gravity', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='energy-potential'), '', '400', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'energy-conservation',
  'Conservation of Energy: Free Fall',
  E'In a closed system without friction, mechanical energy is conserved:\n\n$$E_{{total}} = KE + PE = \\text{constant}$$\n\nAt the highest point: $E = PE_{{max}} = m g h$\n\nAt the lowest point: $E = KE_{{max}} = \\frac{1}{2} m v_{{max}}^2$\n\n**Problem:** A 2 kg object is dropped from a height of 20 meters. Using $g = 10$ m/s² and ignoring air resistance, what is its speed just before hitting the ground?\n\nRound to 1 decimal place.',
  'fill_blank', 'Medium', 'Physics', 130,
  ARRAY['Initial PE = m × g × h = 2 × 10 × 20 = 400 J', 'At ground level: KE_max = PE_max = 400 J', '0.5 × 2 × v² = 400', 'v² = 400', 'v = 20 m/s'],
  ARRAY['energy', 'conservation', 'free-fall', 'kinematics', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='energy-conservation'), '', '20.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'energy-work',
  'Work Done by a Force',
  E'Work is the energy transferred by a force acting over a distance:\n\n$$W = F \\cdot d \\cdot \\cos(\\theta)$$\n\nwhere:\n- $W$ = work (Joules)\n- $F$ = force (Newtons)\n- $d$ = displacement (meters)\n- $\\theta$ = angle between force and displacement\n\nWhen force is parallel to displacement ($\\theta = 0°$): $W = F \\cdot d$\n\n**Problem:** A 50 N force pushes a box horizontally 8 meters across the floor. How much work is done? Assume the force is in the direction of motion.\n\nProvide your answer in Joules.',
  'fill_blank', 'Easy', 'Physics', 105,
  ARRAY['Force is parallel (θ = 0°), so W = F × d', 'W = 50 × 8'],
  ARRAY['work', 'energy', 'force', 'displacement', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='energy-work'), '', '400', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- MOTION GRAPHS & FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'motion-graph-interpretation',
  'Position-Time Graph: Reading Velocity',
  E'On a position-time (s-t) graph:\n- The vertical axis represents position (s) in meters\n- The horizontal axis represents time (t) in seconds\n- The **slope** of the line represents velocity: $v = \\frac{\\Delta s}{\\Delta t}$\n\n**Graph Example:**\n\n<svg width="300" height="250" viewBox="0 0 300 250" style="border: 1px solid rgba(201,168,76,0.3); background: rgba(10,9,6,0.5); margin: 1rem 0; border-radius: 4px;">\n  <!-- Grid -->\n  <g stroke="rgba(201,168,76,0.15)" stroke-width="0.5">\n    <line x1="40" y1="10" x2="40" y2="200"/>\n    <line x1="40" y1="200" x2="280" y2="200"/>\n  </g>\n  <!-- Axis labels -->\n  <text x="260" y="220" font-size="12" fill="#C9A84C" font-family="DM Mono, monospace">time (s)</text>\n  <text x="10" y="30" font-size="12" fill="#C9A84C" font-family="DM Mono, monospace">pos (m)</text>\n  <!-- Tick marks and numbers -->\n  <text x="35" y="215" font-size="10" fill="#8A7D65" text-anchor="end">0</text>\n  <text x="115" y="215" font-size="10" fill="#8A7D65" text-anchor="middle">5</text>\n  <text x="195" y="215" font-size="10" fill="#8A7D65" text-anchor="middle">10</text>\n  <text x="275" y="215" font-size="10" fill="#8A7D65" text-anchor="end">15</text>\n  <text x="35" y="205" font-size="10" fill="#8A7D65" text-anchor="end">0</text>\n  <text x="35" y="125" font-size="10" fill="#8A7D65" text-anchor="end">15</text>\n  <text x="35" y="45" font-size="10" fill="#8A7D65" text-anchor="end">30</text>\n  <!-- The line through (0,0) and (5,30) -->\n  <line x1="40" y1="200" x2="120" y2="40" stroke="#2AC87D" stroke-width="2"/>\n  <!-- Points -->\n  <circle cx="40" cy="200" r="3" fill="#2AC87D"/>\n  <circle cx="120" cy="40" r="3" fill="#2AC87D"/>\n  <!-- Labels for points -->\n  <text x="40" y="225" font-size="11" fill="#D4CCBC" text-anchor="middle" font-family="DM Mono, monospace">(0,0)</text>\n  <text x="135" y="25" font-size="11" fill="#D4CCBC" font-family="DM Mono, monospace">(5,30)</text>\n</svg>\n\n**Problem:** The graph above shows position vs. time. What is the velocity of the object?\n\nProvide your answer in m/s.',
  'fill_blank', 'Easy', 'Physics', 95,
  ARRAY['Slope = Δs / Δt = (30 - 0) / (5 - 0)', 'slope = 30 / 5'],
  ARRAY['motion', 'kinematics', 'graphs', 'velocity', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='motion-graph-interpretation'), '', '6', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'motion-graph-area',
  'Velocity-Time Graph: Displacement from Area',
  E'On a velocity-time (v-t) graph:\n- The vertical axis represents velocity (v) in m/s\n- The horizontal axis represents time (t) in seconds\n- The **area under the curve** represents displacement: $s = \\int v \\, dt$\n\nFor constant velocity (rectangular area): $\\text{Area} = v \\cdot t$\n\n**Graph Example:**\n\n<svg width="300" height="250" viewBox="0 0 300 250" style="border: 1px solid rgba(201,168,76,0.3); background: rgba(10,9,6,0.5); margin: 1rem 0; border-radius: 4px;">\n  <!-- Axes -->\n  <g stroke="rgba(201,168,76,0.15)" stroke-width="0.5">\n    <line x1="40" y1="10" x2="40" y2="200"/>\n    <line x1="40" y1="200" x2="280" y2="200"/>\n  </g>\n  <!-- Axis labels -->\n  <text x="260" y="220" font-size="12" fill="#C9A84C" font-family="DM Mono, monospace">time (s)</text>\n  <text x="10" y="30" font-size="12" fill="#C9A84C" font-family="DM Mono, monospace">vel (m/s)</text>\n  <!-- Rectangle for constant velocity v=12 m/s for t=8s -->\n  <rect x="40" y="80" width="240" height="120" fill="rgba(42,200,125,0.2)" stroke="#2AC87D" stroke-width="2"/>\n  <!-- Area label -->\n  <text x="160" y="145" font-size="14" fill="#2AC87D" text-anchor="middle" font-weight="bold">Area = 12 × 8 = 96 m</text>\n  <!-- Tick marks -->\n  <text x="35" y="205" font-size="10" fill="#8A7D65" text-anchor="end">0</text>\n  <text x="120" y="215" font-size="10" fill="#8A7D65" text-anchor="middle">4</text>\n  <text x="200" y="215" font-size="10" fill="#8A7D65" text-anchor="middle">8</text>\n  <text x="35" y="205" font-size="10" fill="#8A7D65" text-anchor="end">0</text>\n  <text x="35" y="85" font-size="10" fill="#8A7D65" text-anchor="end">12</text>\n  <!-- Velocity marker -->\n  <line x1="35" y1="80" x2="40" y2="80" stroke="#8A7D65" stroke-width="1"/>\n</svg>\n\n**Problem:** The graph above shows a constant velocity of 12 m/s maintained for 8 seconds. What is the displacement during this time interval?\n\nProvide your answer in meters.',
  'fill_blank', 'Easy', 'Physics', 100,
  ARRAY['For rectangular area: displacement = base × height', 'displacement = 8 × 12'],
  ARRAY['motion', 'kinematics', 'graphs', 'displacement', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='motion-graph-area'), '', '96', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'motion-acceleration-graph',
  'Acceleration-Time Graph: Velocity Change',
  E'On an acceleration-time (a-t) graph:\n- The vertical axis represents acceleration (a) in m/s²\n- The horizontal axis represents time (t) in seconds\n- The **area under the curve** represents the change in velocity: $\\Delta v = \\int a \\, dt$\n\nFor constant acceleration (rectangular area): $\\Delta v = a \\cdot t$\n\n**Graph Example:**\n\n<svg width="300" height="250" viewBox="0 0 300 250" style="border: 1px solid rgba(201,168,76,0.3); background: rgba(10,9,6,0.5); margin: 1rem 0; border-radius: 4px;">\n  <!-- Axes -->\n  <g stroke="rgba(201,168,76,0.15)" stroke-width="0.5">\n    <line x1="40" y1="10" x2="40" y2="200"/>\n    <line x1="40" y1="200" x2="280" y2="200"/>\n  </g>\n  <!-- Axis labels -->\n  <text x="260" y="220" font-size="12" fill="#C9A84C" font-family="DM Mono, monospace">time (s)</text>\n  <text x="10" y="30" font-size="12" fill="#C9A84C" font-family="DM Mono, monospace">accel (m/s²)</text>\n  <!-- Rectangle for constant acceleration a=3 m/s² for t=6s -->\n  <rect x="40" y="100" width="180" height="100" fill="rgba(201,168,76,0.2)" stroke="#C9A84C" stroke-width="2"/>\n  <!-- Area label -->\n  <text x="130" y="155" font-size="14" fill="gold" text-anchor="middle" font-weight="bold">Area = 3 × 6 = 18 m/s</text>\n  <!-- Tick marks -->\n  <text x="35" y="205" font-size="10" fill="#8A7D65" text-anchor="end">0</text>\n  <text x="100" y="215" font-size="10" fill="#8A7D65" text-anchor="middle">3</text>\n  <text x="165" y="215" font-size="10" fill="#8A7D65" text-anchor="middle">6</text>\n  <text x="220" y="215" font-size="10" fill="#8A7D65" text-anchor="middle">9</text>\n  <text x="35" y="205" font-size="10" fill="#8A7D65" text-anchor="end">0</text>\n  <text x="35" y="105" font-size="10" fill="#8A7D65" text-anchor="end">3</text>\n  <!-- Acceleration marker -->\n  <line x1="35" y1="100" x2="40" y2="100" stroke="#8A7D65" stroke-width="1"/>\n</svg>\n\n**Problem:** The graph above shows a constant acceleration of 3 m/s² for 6 seconds. If the object starts from rest ($v_i = 0$), what is the final velocity?\n\nProvide your answer in m/s.',
  'fill_blank', 'Easy', 'Physics', 105,
  ARRAY['Area under curve = change in velocity', 'Δv = 3 × 6 = 18 m/s', 'v_f = 0 + 18'],
  ARRAY['motion', 'kinematics', 'graphs', 'acceleration', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='motion-acceleration-graph'), '', '18', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- CENTRIFUGAL EFFECTS (Rotating Reference Frames)
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'centrifugal-effect',
  'Centrifugal Effect in Rotating Frame',
  E'In a rotating reference frame (non-inertial), an object appears to experience an outward "centrifugal force":\n\n$$F_{{centrifugal}} = m \\cdot \\omega^2 \\cdot r$$\n\nThis is a fictitious force—it''s actually the centripetal acceleration needed to keep the object in circular motion, as viewed from the rotating frame.\n\n**Problem:** A 70 kg person sits on a merry-go-round at radius 3 meters from the center. The merry-go-round rotates at $\\omega = 2$ rad/s. What centrifugal force does the person experience in the rotating frame?\n\nProvide your answer in Newtons.',
  'fill_blank', 'Medium', 'Physics', 125,
  ARRAY['F = m × ω² × r', 'F = 70 × (2)² × 3', 'F = 70 × 4 × 3'],
  ARRAY['centrifugal', 'circular-motion', 'rotating-frame', 'non-inertial', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='centrifugal-effect'), '', '840', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'centrifugal-max-speed-curve',
  'Maximum Speed on a Horizontal Curve',
  E'When a vehicle travels on a horizontal curve, friction provides the centripetal force:\n\n$$f = \\mu \\cdot N = m \\cdot \\frac{v^2}{r}$$\n\nFor a car on a horizontal surface: $N = mg$, so:\n\n$$v_{{max}} = \\sqrt{\\mu \\cdot g \\cdot r}$$\n\n**Problem:** A car with tire-road friction coefficient $\\mu = 0.8$ navigates a horizontal curve with radius 100 meters. Using $g = 10$ m/s², what is the maximum safe speed to prevent skidding?\n\nRound to 1 decimal place.',
  'fill_blank', 'Hard', 'Physics', 145,
  ARRAY['v_max = √(μ × g × r)', 'v_max = √(0.8 × 10 × 100)', 'v_max = √800'],
  ARRAY['circular-motion', 'friction', 'centripetal', 'vehicle-dynamics', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='centrifugal-max-speed-curve'), '', '28.3', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- COMPLEX KINEMATICS & DYNAMICS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'projectile-motion-range',
  'Projectile Motion: Horizontal Range',
  E'For a projectile launched at angle $\\theta$ with initial velocity $v_0$:\n\n$$\\text{Range} = \\frac{v_0^2 \\sin(2\\theta)}{g}$$\n\nFor a horizontal launch ($\\theta = 0°$), use separate equations for horizontal and vertical motion:\n\n$$x = v_0 \\cdot t$$\n$$y = \\frac{1}{2} g t^2$$\n\n**Problem:** A ball is launched horizontally from a cliff at 20 m/s. The cliff is 45 meters tall. Using $g = 10$ m/s², how far from the base of the cliff does the ball land?\n\nRound to 1 decimal place.',
  'fill_blank', 'Hard', 'Physics', 150,
  ARRAY['First, find time to fall 45 m: 45 = 0.5 × 10 × t²', 't² = 9, so t = 3 s', 'Horizontal distance: x = 20 × 3 = 60 m'],
  ARRAY['projectile-motion', 'kinematics', 'dynamics', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='projectile-motion-range'), '', '60.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'incline-motion',
  'Motion on an Inclined Plane',
  E'For an object on a frictionless incline at angle $\\theta$:\n\nThe component of gravitational force along the incline:\n$$F_{{parallel}} = m g \\sin(\\theta)$$\n\nAcceleration down the incline:\n$$a = g \\sin(\\theta)$$\n\n**Problem:** A 5 kg block slides down a frictionless incline at $\\theta = 30°$. Using $g = 10$ m/s², what is the acceleration down the incline? Use $\\sin(30°) = 0.5$.\n\nProvide your answer in m/s².',
  'fill_blank', 'Medium', 'Physics', 120,
  ARRAY['a = g × sin(30°)', 'a = 10 × 0.5'],
  ARRAY['incline', 'kinematics', 'dynamics', 'gravity', 'physics'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='incline-motion'), '', '5', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- MULTIPLE CHOICE THEORY PROBLEMS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'physics-concept-inertia',
  'Understanding Inertia (Newton''s First Law)',
  E'Newton''s First Law of Motion states that an object at rest stays at rest, and an object in motion stays in motion at constant velocity, unless acted upon by an external force.\n\nThis property is called **inertia**.\n\n**Question:** Which of the following best describes inertia?',
  'multiple_choice', 'Easy', 'Physics', 90,
  ARRAY['Think about what happens without forces', 'Inertia is NOT a force itself'],
  ARRAY['newtons-law', 'inertia', 'motion', 'physics-concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='physics-concept-inertia'), 'A', 'The tendency of an object to resist changes in its motion', true, 0),
((SELECT id FROM problems WHERE slug='physics-concept-inertia'), 'B', 'A force that slows down moving objects', false, 1),
((SELECT id FROM problems WHERE slug='physics-concept-inertia'), 'C', 'The speed at which an object travels', false, 2),
((SELECT id FROM problems WHERE slug='physics-concept-inertia'), 'D', 'The gravitational attraction between masses', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'physics-concept-centripetal',
  'Direction of Centripetal Force',
  E'An object moving in a circle at constant speed has an associated acceleration called centripetal acceleration, which is produced by centripetal force.\n\n**Question:** In which direction does the centripetal force on an object point during uniform circular motion?',
  'multiple_choice', 'Medium', 'Physics', 100,
  ARRAY['Think about what causes circular motion', 'The object would fly off in a straight line without this force'],
  ARRAY['circular-motion', 'centripetal-force', 'direction', 'physics-concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='physics-concept-centripetal'), 'A', 'Toward the center of the circular path', true, 0),
((SELECT id FROM problems WHERE slug='physics-concept-centripetal'), 'B', 'Away from the center (outward)', false, 1),
((SELECT id FROM problems WHERE slug='physics-concept-centripetal'), 'C', 'Tangent to the circle', false, 2),
((SELECT id FROM problems WHERE slug='physics-concept-centripetal'), 'D', 'Perpendicular to the velocity vector', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'physics-concept-energy-transfer',
  'Energy Transfer and Conservation',
  E'**Question:** A ball is thrown upward. As it rises to its maximum height, what happens to its energy?',
  'multiple_choice', 'Medium', 'Physics', 105,
  ARRAY['At max height, velocity is zero', 'Think about KE and PE'],
  ARRAY['energy', 'conservation', 'kinematics', 'physics-concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='physics-concept-energy-transfer'), 'A', 'Kinetic energy decreases; potential energy increases', true, 0),
((SELECT id FROM problems WHERE slug='physics-concept-energy-transfer'), 'B', 'Both kinetic and potential energy increase', false, 1),
((SELECT id FROM problems WHERE slug='physics-concept-energy-transfer'), 'C', 'All kinetic energy vanishes', false, 2),
((SELECT id FROM problems WHERE slug='physics-concept-energy-transfer'), 'D', 'Energy is destroyed', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- Short Answer Problems
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'physics-explain-freefall',
  'Explain Free Fall with Gravity',
  E'**Question:** In free fall (ignoring air resistance), all objects accelerate downward at the same rate (approximately 10 m/s² on Earth), regardless of their mass.\n\nWhy does a heavy object not fall faster than a light object?',
  'short_answer', 'Medium', 'Physics', 110,
  ARRAY['Think about Newton''s Second Law: F = ma', 'The gravitational force is proportional to mass'],
  ARRAY['gravity', 'free-fall', 'kinematics', 'physics-concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='physics-explain-freefall'), '', 'Because gravitational force is proportional to mass; F = mg, so a = F/m = g (mass cancels)', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'physics-explain-centrifugal-fictitious',
  'Centrifugal Force: Real or Fictitious?',
  E'**Question:** Is centrifugal force a "real" force in classical physics?',
  'short_answer', 'Hard', 'Physics', 130,
  ARRAY['Think about inertial vs non-inertial reference frames', 'What provides the centripetal force?'],
  ARRAY['centrifugal', 'circular-motion', 'reference-frames', 'physics-concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='physics-explain-centrifugal-fictitious'), '', 'No, centrifugal force is fictitious—it appears only in rotating (non-inertial) reference frames', false, 0)
ON CONFLICT DO NOTHING;
