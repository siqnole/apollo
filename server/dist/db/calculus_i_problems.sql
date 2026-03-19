-- ── Calculus I: Limits, Derivatives, and Applications ──────────────────────
-- Run: psql -U postgres -d apollo -h localhost -f calculus_i_problems.sql
-- Requires LaTeX rendering (KaTeX) in the frontend.

-- ─────────────────────────────────────────────────────────────────────────
-- LIMITS & CONTINUITY
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'limit-direct-substitution',
  'Evaluate a Limit by Direct Substitution',
  E'Direct substitution is the simplest method for finding limits. If $f$ is continuous at $a$, then:\n\n$$\\lim_{x \\to a} f(x) = f(a)$$\n\n**Problem:** Evaluate\n\n$$\\lim_{x \\to 2} (3x^2 - 5x + 1)$$\n\nRound to the nearest integer.',
  'fill_blank', 'Easy', 'Calculus I', 100,
  ARRAY['Substitute x = 2 into the equation', '3(2)² - 5(2) + 1', '= 12 - 10 + 1'],
  ARRAY['limits', 'continuity', 'direct-substitution', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='limit-direct-substitution'), '', '3', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'limit-indeterminate-form',
  'Limit with Indeterminate Form: Factoring',
  E'When direct substitution gives $\\frac{0}{0}$, try factoring and canceling.\n\n**Problem:** Evaluate\n\n$$\\lim_{x \\to 3} \\frac{x^2 - 9}{x - 3}$$\n\nRound to 1 decimal place.',
  'fill_blank', 'Medium', 'Calculus I', 130,
  ARRAY['x² - 9 = (x-3)(x+3)', 'Cancel (x-3)', 'lim (x+3) = 3+3 = 6'],
  ARRAY['limits', 'indeterminate-form', 'factoring', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='limit-indeterminate-form'), '', '6.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- DERIVATIVES: DEFINITION & RULES
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'derivative-power-rule',
  'Power Rule for Derivatives',
  E'The power rule states:\n\n$$\\frac{d}{dx}[x^n] = n x^{n-1}$$\n\n**Problem:** Find $\\frac{dy}{dx}$ for $y = 5x^4 - 3x^2 + 7$\n\nProvide your answer as a polynomial (e.g., 20x^3 - 6x).',
  'fill_blank', 'Easy', 'Calculus I', 110,
  ARRAY['Apply power rule to each term', '5 × 4x³ = 20x³', '-3 × 2x = -6x', 'Constant 7 → 0'],
  ARRAY['derivatives', 'power-rule', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='derivative-power-rule'), '', '20x^3 - 6x', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'derivative-product-rule',
  'Product Rule for Derivatives',
  E'The product rule states:\n\n$$\\frac{d}{dx}[f(x)g(x)] = f''(x)g(x) + f(x)g''(x)$$\n\n**Problem:** Find $\\frac{d}{dx}[(3x^2)(x^3 + 1)]$\n\nProvide your answer simplified (e.g., 15x^4 + 6x).',
  'fill_blank', 'Medium', 'Calculus I', 140,
  ARRAY['Let f(x) = 3x², g(x) = x³ + 1', 'f''(x) = 6x, g''(x) = 3x²', 'f''g + fg'' = 6x(x³+1) + 3x²(3x²)', '= 6x⁴ + 6x + 9x⁴', '= 15x⁴ + 6x'],
  ARRAY['derivatives', 'product-rule', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='derivative-product-rule'), '', '15x^4 + 6x', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'derivative-chain-rule',
  'Chain Rule for Derivatives',
  E'The chain rule states:\n\n$$\\frac{d}{dx}[f(g(x))] = f''(g(x)) \\cdot g''(x)$$\n\n**Problem:** Find $\\frac{d}{dx}[\\sin(3x^2 + 1)]$\n\nProvide your answer (e.g., cos(3x^2 + 1) * 6x).',
  'fill_blank', 'Medium', 'Calculus I', 145,
  ARRAY['Outer function: sin(u), derivative: cos(u)', 'Inner function: u = 3x² + 1, derivative: 6x', 'Chain rule: cos(3x² + 1) × 6x'],
  ARRAY['derivatives', 'chain-rule', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='derivative-chain-rule'), '', 'cos(3x^2 + 1) * 6x', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- DERIVATIVE APPLICATIONS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'critical-points-optimization',
  'Find Critical Points and Extrema',
  E'Critical points occur where $f''(x) = 0$ or $f''(x)$ is undefined. Use the first derivative test:\n- If $f''$ changes from + to - : local maximum\n- If $f''$ changes from - to + : local minimum\n\n**Problem:** Find the x-coordinate of the local maximum of $f(x) = -2x^2 + 8x - 3$\n\nRound to 1 decimal place.',
  'fill_blank', 'Medium', 'Calculus I', 150,
  ARRAY['f''(x) = -4x + 8', 'Set f''(x) = 0: -4x + 8 = 0', 'x = 2', 'Second derivative f''''(x) = -4 < 0, so it''s a maximum'],
  ARRAY['derivatives', 'critical-points', 'optimization', 'extrema', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='critical-points-optimization'), '', '2.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'related-rates',
  'Related Rates Problem',
  E'In related rates problems, quantities change over time. Use implicit differentiation with the chain rule.\n\n**Problem:** A spherical balloon is being inflated. The radius is increasing at 2 cm/s. How fast is the volume increasing when the radius is 5 cm?\n\nUse $V = \\frac{4}{3}\\pi r^3$ and round to 2 decimal places (in cm³/s). Use $\\pi \\approx 3.14159$.',
  'fill_blank', 'Hard', 'Calculus I', 160,
  ARRAY['V = (4/3)πr³', 'dV/dt = 4πr² × dr/dt', 'dV/dt = 4π(5²) × 2', '= 4π(25)(2) = 200π'],
  ARRAY['related-rates', 'derivatives', 'implicit-differentiation', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='related-rates'), '', '628.32', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- INTEGRATION: ANTIDERIVATIVES & BASICS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'antiderivative-power-rule',
  'Power Rule for Integration',
  E'The power rule for integration states:\n\n$$\\int x^n \\, dx = \\frac{x^{n+1}}{n+1} + C \\quad (n \\neq -1)$$\n\n**Problem:** Evaluate $\\int (6x^3 - 2x + 5) \\, dx$\n\nProvide your answer with C (e.g., 1.5x^4 - x^2 + 5x + C).',
  'fill_blank', 'Easy', 'Calculus I', 120,
  ARRAY['Integrate term by term', '6x³ → 6 × x⁴/4 = 1.5x⁴', '-2x → -2 × x²/2 = -x²', '5 → 5x', 'Add constant C'],
  ARRAY['integrals', 'antiderivatives', 'power-rule', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='antiderivative-power-rule'), '', '1.5x^4 - x^2 + 5x + C', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'definite-integral-fundamental-theorem',
  'Fundamental Theorem of Calculus',
  E'The Fundamental Theorem of Calculus states:\n\n$$\\int_a^b f(x) \\, dx = F(b) - F(a)$$\n\nwhere $F$ is an antiderivative of $f$.\n\n**Problem:** Evaluate $\\int_1^3 (4x - 1) \\, dx$\n\nRound to 1 decimal place.',
  'fill_blank', 'Medium', 'Calculus I', 135,
  ARRAY['Antiderivative: F(x) = 2x² - x', 'F(3) = 2(9) - 3 = 15', 'F(1) = 2(1) - 1 = 1', 'F(3) - F(1) = 15 - 1 = 14'],
  ARRAY['integrals', 'definite-integral', 'fundamental-theorem', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='definite-integral-fundamental-theorem'), '', '14.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- APPLICATIONS OF INTEGRATION
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'area-between-curves',
  'Area Between Two Curves',
  E'The area between curves $y = f(x)$ and $y = g(x)$ from $a$ to $b$ is:\n\n$$A = \\int_a^b |f(x) - g(x)| \\, dx$$\n\nAssuming $f(x) \\geq g(x)$ on $[a,b]$:\n\n$$A = \\int_a^b [f(x) - g(x)] \\, dx$$\n\n**Problem:** Find the area between $y = x^2$ and $y = 2x$ from $x = 0$ to $x = 2$.\n\nRound to 2 decimal places.',
  'fill_blank', 'Hard', 'Calculus I', 160,
  ARRAY['Determine which curve is on top: 2x ≥ x² on [0,2]', 'A = ∫₀² (2x - x²) dx', '= [x² - x³/3]₀²', '= 4 - 8/3 = 12/3 - 8/3 = 4/3'],
  ARRAY['area', 'integrals', 'applications', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='area-between-curves'), '', '1.33', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- CONCEPT PROBLEMS: CALCULUS I
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-derivative-interpretation',
  'Derivative as Rate of Change',
  E'**Question:** If $f(x)$ represents the position of an object at time $x$, what does $f''(x)$ represent?',
  'multiple_choice', 'Easy', 'Calculus I', 110,
  ARRAY['The derivative represents the instantaneous rate of change', 'Position → velocity, velocity → acceleration'],
  ARRAY['derivatives', 'rates-of-change', 'physics-calculus', 'concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-derivative-interpretation'), 'A', 'The velocity (rate of change of position)', true, 0),
((SELECT id FROM problems WHERE slug='concept-derivative-interpretation'), 'B', 'The acceleration', false, 1),
((SELECT id FROM problems WHERE slug='concept-derivative-interpretation'), 'C', 'The maximum value of the function', false, 2),
((SELECT id FROM problems WHERE slug='concept-derivative-interpretation'), 'D', 'The integral of the function', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-integral-interpretation',
  'Definite Integral as Accumulated Area',
  E'**Question:** What does $\\int_a^b f(x) \\, dx$ represent geometrically when $f(x) \\geq 0$?',
  'multiple_choice', 'Easy', 'Calculus I', 115,
  ARRAY['Integral is the reverse of differentiation', 'Accumulated quantity', 'Area under curve'],
  ARRAY['integrals', 'geometric-interpretation', 'concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-integral-interpretation'), 'A', 'The slope of the curve', false, 0),
((SELECT id FROM problems WHERE slug='concept-integral-interpretation'), 'B', 'The area under the curve from a to b', true, 1),
((SELECT id FROM problems WHERE slug='concept-integral-interpretation'), 'C', 'The derivative at point a', false, 2),
((SELECT id FROM problems WHERE slug='concept-integral-interpretation'), 'D', 'The average value of f', false, 3)
ON CONFLICT DO NOTHING;
