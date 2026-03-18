-- ── Calculus III: Multivariable Calculus ────────────────────────────────────
-- Run: psql -U postgres -d apollo -h localhost -f calculus_iii_problems.sql
-- Requires LaTeX rendering (KaTeX) in the frontend.

-- ─────────────────────────────────────────────────────────────────────────
-- PARTIAL DERIVATIVES
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'partial-derivative-first',
  'First Partial Derivatives',
  E'For $f(x,y)$, partial derivatives treat one variable as constant:\n\n$$\\frac{\\partial f}{\\partial x} = f_x, \\quad \\frac{\\partial f}{\\partial y} = f_y$$\n\n**Problem:** Find $\\frac{\\partial f}{\\partial x}$ for $f(x,y) = 3x^2y + 2xy^3 + 5$\n\nProvide your answer (e.g., 6xy + 2y^3).',
  'fill_blank', 'Easy', 'Calculus III', 130,
  ARRAY['Treat y as constant', '∂/∂x(3x²y) = 6xy', '∂/∂x(2xy³) = 2y³', '∂/∂x(5) = 0'],
  ARRAY['partial-derivatives', 'multivariable', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='partial-derivative-first'), '', '6xy + 2y^3', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'partial-derivative-mixed',
  'Mixed Partial Derivatives',
  E'For differentiable functions, **Clairaut''s Theorem** states:\n\n$$f_{xy} = f_{yx}$$\n\n**Problem:** For $f(x,y) = x^3y^2 + x^2y$, find $f_{xy}$ (differentiate first w.r.t. $x$, then $y$).\n\nProvide your answer (e.g., 6x^2y + 2x).',
  'fill_blank', 'Medium', 'Calculus III', 145,
  ARRAY['f_x = ∂/∂x(x³y² + x²y) = 3x²y² + 2xy', 'f_xy = ∂/∂y(3x²y² + 2xy) = 6x²y + 2x'],
  ARRAY['partial-derivatives', 'mixed-partial', 'multivariable', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='partial-derivative-mixed'), '', '6x^2y + 2x', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- CRITICAL POINTS & OPTIMIZATION IN 2D
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'critical-points-2d',
  'Find Critical Points in 2D',
  E'Critical points satisfy $f_x = 0$ and $f_y = 0$.\n\n**Problem:** Find the critical point(s) of $f(x,y) = x^2 + y^2 - 4x + 6y + 5$\n\nFormat: (x, y) with integer coordinates.',
  'fill_blank', 'Medium', 'Calculus III', 150,
  ARRAY['f_x = 2x - 4', 'f_y = 2y + 6', '2x - 4 = 0 → x = 2', '2y + 6 = 0 → y = -3', 'Critical point: (2, -3)'],
  ARRAY['critical-points', 'optimization', 'multivariable', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='critical-points-2d'), '', '(2, -3)', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'second-derivative-test',
  'Second Derivative Test (Hessian)',
  E'At critical point $(x_0, y_0)$, compute:\n\n$$D = f_{xx} f_{yy} - (f_{xy})^2$$\n\n- If $D > 0$ and $f_{xx} > 0$: local minimum\n- If $D > 0$ and $f_{xx} < 0$: local maximum\n- If $D < 0$: saddle point\n\n**Problem:** For $f(x,y) = x^2 - y^2$ at critical point $(0,0)$, classify it.\n\nAnswer: minimum, maximum, or saddle',
  'fill_blank', 'Hard', 'Calculus III', 160,
  ARRAY['f_x = 2x, f_y = -2y → critical point (0,0)', 'f_xx = 2, f_yy = -2, f_xy = 0', 'D = (2)(-2) - 0² = -4 < 0', 'Since D < 0, (0,0) is a saddle point'],
  ARRAY['critical-points', 'hessian', 'optimization', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='second-derivative-test'), '', 'saddle', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- GRADIENT & DIRECTIONAL DERIVATIVE
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'gradient-vector',
  'Gradient Vector',
  E'The gradient of $f(x,y)$ is:\n\n$$\\nabla f = \\langle f_x, f_y \\rangle$$\n\nIt points in the direction of steepest increase.\n\n**Problem:** Find $\\nabla f$ at point $(1, 2)$ for $f(x,y) = 2x^2 + 3xy$\n\nFormat: (f_x, f_y) evaluated at the point.',
  'fill_blank', 'Easy', 'Calculus III', 135,
  ARRAY['f_x = 4x + 3y', 'f_y = 3x', 'At (1, 2): f_x = 4(1) + 3(2) = 10, f_y = 3(1) = 3'],
  ARRAY['gradient', 'directional-derivative', 'multivariable', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='gradient-vector'), '', '(10, 3)', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'directional-derivative',
  'Directional Derivative',
  E'The directional derivative in direction of unit vector $\\mathbf{u} = \\langle a, b \\rangle$ is:\n\n$$D_\\mathbf{u}f = \\nabla f \\cdot \\mathbf{u}$$\n\n**Problem:** For $f(x,y) = 2x + 3y$, find the directional derivative at $(1,1)$ in direction of $\\mathbf{u} = \\frac{1}{\\sqrt{2}}\\langle 1, 1 \\rangle$.\n\nRound to 2 decimal places.',
  'fill_blank', 'Medium', 'Calculus III', 155,
  ARRAY['∇f = ⟨2, 3⟩ (constant)', 'D_u f = ⟨2, 3⟩ · (1/√2)⟨1, 1⟩', '= (1/√2)(2 + 3) = 5/√2 ≈ 3.54'],
  ARRAY['directional-derivative', 'gradient', 'multivariable', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='directional-derivative'), '', '3.54', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- MULTIPLE INTEGRALS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'double-integral-rectangular',
  'Double Integral over Rectangular Region',
  E'For a rectangular region $R = [a,b] \\times [c,d]$:\n\n$$\\iint_R f(x,y) \\, dA = \\int_a^b \\int_c^d f(x,y) \\, dy \\, dx$$\n\n**Problem:** Evaluate $\\iint_R (2x + 3y) \\, dA$ over $R = [0,1] \\times [0,2]$\n\nRound to 1 decimal place.',
  'fill_blank', 'Medium', 'Calculus III', 160,
  ARRAY['∫₀² (2x + 3y) dy = [2xy + 3y²/2]₀² = 4x + 6', '∫₀¹ (4x + 6) dx = [2x² + 6x]₀¹ = 2 + 6 = 8'],
  ARRAY['double-integral', 'multiple-integrals', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='double-integral-rectangular'), '', '8.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'polar-coordinates-integral',
  'Double Integral in Polar Coordinates',
  E'In polar coordinates: $x = r\\cos\\theta$, $y = r\\sin\\theta$, $dA = r \\, dr \\, d\\theta$\n\n$$\\iint_R f(x,y) \\, dA = \\int_\\alpha^\\beta \\int_{r_1}^{r_2} f(r\\cos\\theta, r\\sin\\theta) r \\, dr \\, d\\theta$$\n\n**Problem:** Find area of circle with radius 3 using polar coords:\n\n$$\\int_0^{2\\pi} \\int_0^3 r \\, dr \\, d\\theta$$\n\nUse $\\pi \\approx 3.14159$. Round to 1 decimal place.',
  'fill_blank', 'Hard', 'Calculus III', 175,
  ARRAY['∫₀³ r dr = [r²/2]₀³ = 9/2', '∫₀²ᵖ (9/2) dθ = (9/2) × 2π = 9π'],
  ARRAY['polar-coordinates', 'double-integral', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='polar-coordinates-integral'), '', '28.3', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- VECTOR CALCULUS: LINE & SURFACE INTEGRALS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'line-integral-scalar',
  'Line Integral of Scalar Function',
  E'For parametric curve $\\mathbf{r}(t) = \\langle x(t), y(t) \\rangle$:\n\n$$\\int_C f(x,y) \\, ds = \\int_a^b f(x(t), y(t)) |\\mathbf{r}''(t)| \\, dt$$\n\nwhere $|\\mathbf{r}''(t)| = \\sqrt{(dx/dt)^2 + (dy/dt)^2}$\n\n**Problem:** Integrate $f(x,y) = x + y$ along $x = t$, $y = t^2$ from $t = 0$ to $t = 1$.\n\nRound to 2 decimal places.',
  'fill_blank', 'Hard', 'Calculus III', 175,
  ARRAY['dx/dt = 1, dy/dt = 2t', '|r''(t)| = √(1 + 4t²)', 'f(x,y) = t + t²', '∫₀¹ (t + t²)√(1 + 4t²) dt ≈ 1.44'],
  ARRAY['line-integral', 'vector-calculus', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='line-integral-scalar'), '', '1.44', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- CONCEPT PROBLEMS: CALCULUS III
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-gradient-direction',
  'Gradient Points in Direction of Max Increase',
  E'**Question:** What does the gradient vector $\\nabla f$ represent geometrically?',
  'multiple_choice', 'Easy', 'Calculus III', 125,
  ARRAY['∇f points uphill', 'Magnitude = steepness'],
  ARRAY['gradient', 'multivariable', 'concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-gradient-direction'), 'A', 'The direction of steepest increase and its magnitude is the rate of increase', true, 0),
((SELECT id FROM problems WHERE slug='concept-gradient-direction'), 'B', 'A vector perpendicular to the surface', false, 1),
((SELECT id FROM problems WHERE slug='concept-gradient-direction'), 'C', 'The direction of steepest decrease', false, 2),
((SELECT id FROM problems WHERE slug='concept-gradient-direction'), 'D', 'A constant vector for any function', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-hessian-matrix',
  'Hessian Matrix and Optimization',
  E'**Question:** In 2D optimization, what is the Hessian matrix used for?',
  'multiple_choice', 'Medium', 'Calculus III', 145,
  ARRAY['H = [[f_xx, f_xy], [f_xy, f_yy]]', 'Determines nature of critical points'],
  ARRAY['hessian', 'critical-points', 'optimization', 'concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-hessian-matrix'), 'A', 'To check if a critical point is a min, max, or saddle point', true, 0),
((SELECT id FROM problems WHERE slug='concept-hessian-matrix'), 'B', 'To find where f_x = 0 and f_y = 0', false, 1),
((SELECT id FROM problems WHERE slug='concept-hessian-matrix'), 'C', 'To compute the directional derivative', false, 2),
((SELECT id FROM problems WHERE slug='concept-hessian-matrix'), 'D', 'To integrate over a region', false, 3)
ON CONFLICT DO NOTHING;
