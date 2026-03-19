-- ── Differential Equations: ODEs, Methods & Applications ──────────────────
-- Run: psql -U postgres -d apollo -h localhost -f differential_equations_problems.sql
-- Requires LaTeX rendering (KaTeX) in the frontend.

-- ─────────────────────────────────────────────────────────────────────────
-- SEPARABLE EQUATIONS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'separable-equation-basic',
  'Solve Separable Differential Equation',
  E'A separable equation has form $\\frac{dy}{dx} = f(x)g(y)$. Separate variables and integrate:\n\n$$\\int \\frac{dy}{g(y)} = \\int f(x) \\, dx$$\n\n**Problem:** Solve $\\frac{dy}{dx} = 2xy$ with initial condition $y(0) = 1$.\n\nProvide the solution $y = f(x)$ (e.g., e^(x^2)).',
  'fill_blank', 'Medium', 'Differential Equations', 150,
  ARRAY['Separate: dy/y = 2x dx', 'Integrate: ln|y| = x² + C', 'y = e^(x² + C) = Ae^(x²)', 'y(0) = 1: A = 1', 'Solution: y = e^(x²)'],
  ARRAY['separable', 'differential-equations', 'initial-value'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='separable-equation-basic'), '', 'e^(x^2)', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'exponential-growth-decay',
  'Exponential Growth/Decay Model',
  E'The differential equation $\\frac{dP}{dt} = kP$ models exponential growth ($k > 0$) or decay ($k < 0$).\n\nSolution: $P(t) = P_0 e^{kt}$\n\n**Problem:** A radioactive substance decays with $\\frac{dP}{dt} = -0.5P$. If $P(0) = 100$, find $P(2)$.\n\nRound to 1 decimal place.',
  'fill_blank', 'Easy', 'Differential Equations', 140,
  ARRAY['P(t) = 100 e^(-0.5t)', 'P(2) = 100 e^(-1)', 'e^(-1) ≈ 0.3679', 'P(2) ≈ 36.79'],
  ARRAY['exponential', 'growth-decay', 'differential-equations'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='exponential-growth-decay'), '', '36.8', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- LINEAR FIRST-ORDER EQUATIONS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'linear-first-order-ode',
  'Linear First-Order ODE: Integrating Factor',
  E'Standard form: $\\frac{dy}{dx} + P(x)y = Q(x)$\n\nMultiply by integrating factor $\\mu(x) = e^{\\int P(x) dx}$:\n\n$$\\frac{d}{dx}[\\mu(x)y] = \\mu(x)Q(x)$$\n\n**Problem:** Solve $\\frac{dy}{dx} - y = 0$.\n\nProvide solution $y = f(x)$ (e.g., Ce^x).',
  'fill_blank', 'Medium', 'Differential Equations', 155,
  ARRAY['P(x) = -1, μ(x) = e^(-x)', 'Multiply: e^(-x)dy/dx - e^(-x)y = 0', 'd/dx[e^(-x)y] = 0', 'e^(-x)y = C', 'y = Ce^x'],
  ARRAY['linear-ode', 'integrating-factor', 'differential-equations'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='linear-first-order-ode'), '', 'Ce^x', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- SECOND-ORDER LINEAR EQUATIONS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'homogeneous-second-order',
  'Homogeneous Linear 2nd Order: Characteristic Equation',
  E'For $ay'' + by'' + cy = 0$, find characteristic equation:\n\n$$ar^2 + br + c = 0$$\n\nSolutions depend on roots $r_1, r_2$:\n- Distinct real: $y = c_1 e^{r_1 x} + c_2 e^{r_2 x}$\n- Repeated real: $y = (c_1 + c_2 x)e^{r x}$\n- Complex: $y = e^{\\alpha x}(c_1\\cos\\beta x + c_2\\sin\\beta x)$\n\n**Problem:** Solve $y'' - 3y'' + 2y = 0$.\n\nProvide general solution format (e.g., C1*e^x + C2*e^(2x)).',
  'fill_blank', 'Hard', 'Differential Equations', 170,
  ARRAY['Characteristic eq: r² - 3r + 2 = 0', '(r - 1)(r - 2) = 0', 'r = 1, 2', 'y = C1*e^x + C2*e^(2x)'],
  ARRAY['second-order-ode', 'characteristic-equation', 'differential-equations'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='homogeneous-second-order'), '', 'C1*e^x + C2*e^(2x)', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'nonhomogeneous-undetermined-coefficients',
  'Nonhomogeneous 2nd Order: Undetermined Coefficients',
  E'For $y'' + py'' + qy = f(x)$ where $f(x)$ is polynomial/exponential/trig:\n\n1. Find homogeneous solution $y_h$\n2. Guess particular solution $y_p$ and solve for coefficients\n3. General solution: $y = y_h + y_p$\n\n**Problem:** Solve $y'' - y = 2$.\n\nFor $y_p$, try constant: $y_p = A$. Find $A$.\n\nProvide value of A.',
  'fill_blank', 'Hard', 'Differential Equations', 175,
  ARRAY['Homogeneous: y''''h = C1*e^x + C2*e^(-x)', 'Particular: y_p = A (constant)', 'y''''p = 0, y''''''''p = 0', '0 - A = 2 → A = -2'],
  ARRAY['nonhomogeneous-ode', 'undetermined-coefficients', 'differential-equations'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='nonhomogeneous-undetermined-coefficients'), '', '-2', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- SYSTEMS OF DIFFERENTIAL EQUATIONS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'system-linear-ode',
  'System of Linear ODEs: Matrix Form',
  E'A system can be written as $\\mathbf{x}'' = A\\mathbf{x}$ where $A$ is the coefficient matrix.\n\n**Problem:** Write the system in matrix form:\n\n$$\\begin{cases} x'' = 2x + y \\\\ y'' = x + 2y \\end{cases}$$\n\nProvide coefficient matrix A:\n\nFormat: row 1; row 2 (e.g., 2, 1; 1, 2)',
  'fill_blank', 'Easy', 'Differential Equations', 145,
  ARRAY['Matrix form: [x'', y''] = A[x, y]', 'A = [[2, 1], [1, 2]]'],
  ARRAY['systems-ode', 'matrix-form', 'differential-equations'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='system-linear-ode'), '', '2, 1; 1, 2', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- LAPLACE TRANSFORMS (Introduction)
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'laplace-transform-basic',
  'Laplace Transform of Basic Functions',
  E'The Laplace Transform: $\\mathcal{L}\\{f(t)\\} = F(s) = \\int_0^{\\infty} e^{-st}f(t) \\, dt$\n\nBasic transforms:\n- $\\mathcal{L}\\{1\\} = \\frac{1}{s}$ (for $s > 0$)\n- $\\mathcal{L}\\{e^{at}\\} = \\frac{1}{s - a}$ (for $s > a$)\n- $\\mathcal{L}\\{t\\} = \\frac{1}{s^2}$ (for $s > 0$)\n\n**Problem:** Find $\\mathcal{L}\\{5\\}$.\n\nProvide answer (e.g., 5/s).',
  'fill_blank', 'Easy', 'Differential Equations', 130,
  ARRAY['L{5} = 5 × L{1} = 5 × (1/s) = 5/s'],
  ARRAY['laplace-transform', 'differential-equations'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='laplace-transform-basic'), '', '5/s', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'laplace-solve-ode',
  'Solve ODE Using Laplace Transform',
  E'Steps:\n1. Apply Laplace Transform to ODE\n2. Solve for $F(s) = \\mathcal{L}\\{y\\}$\n3. Apply inverse Laplace transform\n\n**Problem:** Solve $y'' - y = 0$ with $y(0) = 1$, $y''(0) = 0$.\n\nFirst, find $L\\{y''''\\}$ in terms of $s$ and $Y(s)$ (e.g., s^2*Y(s) - s).',
  'fill_blank', 'Hard', 'Differential Equations', 175,
  ARRAY['y(0) = 1, y''(0) = 0', 'L{y''''} = s²Y(s) - sy(0) - y''(0) = s²Y(s) - s'],
  ARRAY['laplace-transform', 'differential-equations', 'solving-ode'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='laplace-solve-ode'), '', 's^2*Y(s) - s', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- QUALITATIVE ANALYSIS: DIRECTION FIELDS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'equilibrium-stability',
  'Equilibrium Points and Stability',
  E'For $\\frac{dy}{dt} = f(y)$, equilibrium points satisfy $f(y_0) = 0$.\n\n- **Stable** (sink): nearby solutions approach $y_0$\n- **Unstable** (source): nearby solutions diverge from $y_0$\n- **Semistable**: stable from one side, unstable from other\n\n**Problem:** For $\\frac{dy}{dt} = y(1 - y)$, find equilibrium points.\n\nFormat: comma-separated (e.g., 0, 1)',
  'fill_blank', 'Medium', 'Differential Equations', 150,
  ARRAY['Set dy/dt = 0: y(1 - y) = 0', 'Solutions: y = 0 or y = 1'],
  ARRAY['equilibrium', 'stability', 'qualitative-analysis', 'differential-equations'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='equilibrium-stability'), '', '0, 1', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- CONCEPT PROBLEMS: DIFFERENTIAL EQUATIONS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-ode-order-linearity',
  'Order and Linearity of ODEs',
  E'**Question:** For the differential equation $y'''' + 2xy = e^x$, what is its **order** and **linearity**?',
  'multiple_choice', 'Easy', 'Differential Equations', 135,
  ARRAY['Order = highest derivative power', 'Linear = linear in y and derivatives'],
  ARRAY['ode-classification', 'concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-ode-order-linearity'), 'A', 'Order 2, nonlinear', false, 0),
((SELECT id FROM problems WHERE slug='concept-ode-order-linearity'), 'B', 'Order 1, linear', true, 1),
((SELECT id FROM problems WHERE slug='concept-ode-order-linearity'), 'C', 'Order 1, nonlinear', false, 2),
((SELECT id FROM problems WHERE slug='concept-ode-order-linearity'), 'D', 'Order 2, linear', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-separable-vs-linear',
  'When to Use Separable vs Integrating Factor',
  E'**Question:** Which method applies to $\\frac{dy}{dx} + \\frac{y}{x} = x$?',
  'multiple_choice', 'Medium', 'Differential Equations', 150,
  ARRAY['Not separable (can''t separate variables)', 'Linear first-order form: y'' + P(x)y = Q(x)'],
  ARRAY['separable', 'linear-ode', 'methods', 'concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-separable-vs-linear'), 'A', 'Separable method', false, 0),
((SELECT id FROM problems WHERE slug='concept-separable-vs-linear'), 'B', 'Integrating factor method (linear 1st order)', true, 1),
((SELECT id FROM problems WHERE slug='concept-separable-vs-linear'), 'C', 'Undetermined coefficients', false, 2),
((SELECT id FROM problems WHERE slug='concept-separable-vs-linear'), 'D', 'Cannot be solved', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-homogeneous-vs-nonhomogeneous',
  'Homogeneous vs Nonhomogeneous Equations',
  E'**Question:** Which best describes $y'''' - 4y = 0$?',
  'multiple_choice', 'Easy', 'Differential Equations', 130,
  ARRAY['Right side = 0: homogeneous', 'Right side ≠ 0: nonhomogeneous'],
  ARRAY['homogeneous', 'nonhomogeneous', 'concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-homogeneous-vs-nonhomogeneous'), 'A', 'Homogeneous linear ODE', true, 0),
((SELECT id FROM problems WHERE slug='concept-homogeneous-vs-nonhomogeneous'), 'B', 'Nonhomogeneous linear ODE', false, 1),
((SELECT id FROM problems WHERE slug='concept-homogeneous-vs-nonhomogeneous'), 'C', 'Nonlinear ODE', false, 2),
((SELECT id FROM problems WHERE slug='concept-homogeneous-vs-nonhomogeneous'), 'D', 'Partial differential equation', false, 3)
ON CONFLICT DO NOTHING;
