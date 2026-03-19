-- ── Calculus II: Integration Techniques, Series, Sequences ─────────────────
-- Run: psql -U postgres -d apollo -h localhost -f calculus_ii_problems.sql
-- Requires LaTeX rendering (KaTeX) in the frontend.

-- ─────────────────────────────────────────────────────────────────────────
-- INTEGRATION TECHNIQUES: SUBSTITUTION & BY PARTS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'u-substitution',
  'U-Substitution (Change of Variables)',
  E'U-substitution reverses the chain rule. If $u = g(x)$, then:\n\n$$\\int f(g(x)) \\cdot g''(x) \\, dx = \\int f(u) \\, du$$\n\n**Problem:** Evaluate $\\int 2x(x^2 + 1)^5 \\, dx$\n\nProvide your answer with C (e.g., (x^2 + 1)^6 / 6 + C).',
  'fill_blank', 'Medium', 'Calculus II', 140,
  ARRAY['Let u = x² + 1', 'Then du = 2x dx', '∫ 2x(x² + 1)⁵ dx = ∫ u⁵ du', '= u⁶/6 + C = (x² + 1)⁶/6 + C'],
  ARRAY['integration', 'u-substitution', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='u-substitution'), '', '(x^2 + 1)^6 / 6 + C', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'integration-by-parts',
  'Integration by Parts',
  E'Integration by parts formula:\n\n$$\\int u \\, dv = uv - \\int v \\, du$$\n\nUse LIATE rule to choose $u$ (Log, Inverse, Algebraic, Trig, Exponential).\n\n**Problem:** Evaluate $\\int x e^x \\, dx$\n\nProvide your answer with C (e.g., x*e^x - e^x + C).',
  'fill_blank', 'Medium', 'Calculus II', 145,
  ARRAY['Let u = x, dv = eˣ dx', 'Then du = dx, v = eˣ', '∫ x eˣ dx = x eˣ - ∫ eˣ dx', '= x eˣ - eˣ + C = eˣ(x - 1) + C'],
  ARRAY['integration', 'integration-by-parts', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='integration-by-parts'), '', 'x*e^x - e^x + C', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'trigonometric-integral',
  'Trigonometric Integrals',
  E'Many trig integrals use identities like $\\sin^2(x) = \\frac{1 - \\cos(2x)}{2}$ and $\\cos^2(x) = \\frac{1 + \\cos(2x)}{2}$.\n\n**Problem:** Evaluate $\\int_0^{\\pi} \\sin^2(x) \\, dx$\n\nRound to 2 decimal places. Use $\\pi \\approx 3.14159$.',
  'fill_blank', 'Hard', 'Calculus II', 160,
  ARRAY['Use identity: sin²(x) = (1 - cos(2x))/2', '∫₀ᵖ (1/2 - (1/2)cos(2x)) dx', '= [x/2 - sin(2x)/4]₀ᵖ', '= (π/2 - 0) - (0 - 0) = π/2'],
  ARRAY['integration', 'trigonometric', 'identities', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='trigonometric-integral'), '', '1.57', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- IMPROPER INTEGRALS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'improper-integral-convergence',
  'Improper Integral with Limit',
  E'An improper integral has limits at infinity. Evaluate using a limit:\n\n$$\\int_a^{\\infty} f(x) \\, dx = \\lim_{t \\to \\infty} \\int_a^t f(x) \\, dx$$\n\n**Problem:** Determine if $\\int_1^{\\infty} \\frac{1}{x^2} \\, dx$ converges or diverges. If it converges, find its value.\n\nAnswer: converge 1 or diverge (e.g., converge 0.5)',
  'fill_blank', 'Hard', 'Calculus II', 165,
  ARRAY['∫ 1/x² dx = -1/x + C', 'lim(t→∞) [-1/x]₁ᵗ = lim(t→∞) [-1/t - (-1)]', '= 0 + 1 = 1', 'Answer: converge 1'],
  ARRAY['improper-integrals', 'convergence', 'limits-at-infinity', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='improper-integral-convergence'), '', 'converge 1', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- SEQUENCES & SERIES
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sequence-limit',
  'Find the Limit of a Sequence',
  E'A sequence $\\{a_n\\}$ converges to $L$ if $\\lim_{n \\to \\infty} a_n = L$.\n\n**Problem:** Find $\\lim_{n \\to \\infty} \\frac{3n + 1}{5n - 2}$\n\nRound to 2 decimal places.',
  'fill_blank', 'Easy', 'Calculus II', 130,
  ARRAY['Divide numerator and denominator by highest power (n)', '(3 + 1/n) / (5 - 2/n)', 'As n → ∞: 1/n → 0', 'Limit = 3/5 = 0.6'],
  ARRAY['sequences', 'limits', 'convergence', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='sequence-limit'), '', '0.60', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'geometric-series-sum',
  'Sum of a Geometric Series',
  E'A geometric series $\\sum_{n=0}^{\\infty} ar^n$ converges if $|r| < 1$ with sum:\n\n$$S = \\frac{a}{1 - r}$$\n\n**Problem:** Find the sum of $\\sum_{n=0}^{\\infty} \\frac{1}{2^n}$\n\nRound to 1 decimal place.',
  'fill_blank', 'Easy', 'Calculus II', 135,
  ARRAY['First term a = 1', 'Common ratio r = 1/2', 'Since |r| < 1, series converges', 'S = 1 / (1 - 1/2) = 1 / (1/2) = 2'],
  ARRAY['series', 'geometric-series', 'convergence', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='geometric-series-sum'), '', '2.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'series-test-divergence',
  'Divergence (nth Term) Test',
  E'If $\\lim_{n \\to \\infty} a_n \\neq 0$ (or DNE), then $\\sum a_n$ diverges.\n\n**Problem:** Does $\\sum_{n=1}^{\\infty} \\frac{n}{n+1}$ converge or diverge?\n\nAnswer: converge or diverge',
  'fill_blank', 'Medium', 'Calculus II', 145,
  ARRAY['Check: lim(n→∞) n/(n+1)', 'Divide by n: lim(n→∞) 1/(1 + 1/n) = 1', 'Since lim ≠ 0, series diverges by divergence test'],
  ARRAY['series', 'convergence-tests', 'divergence-test', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='series-test-divergence'), '', 'diverge', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- POWER SERIES & TAYLOR SERIES
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'taylor-series-expansion',
  'Taylor Series Expansion',
  E'The Taylor series of $f$ centered at $x = a$ is:\n\n$$f(x) = \\sum_{n=0}^{\\infty} \\frac{f^{(n)}(a)}{n!}(x-a)^n$$\n\n**Problem:** Find the first 3 non-zero terms of the Taylor series for $f(x) = e^x$ centered at $a = 0$.\n\nFormat: 1 + x + x^2/2 (e.g., separate terms with +)',
  'fill_blank', 'Hard', 'Calculus II', 170,
  ARRAY['f(x) = eˣ, all derivatives = eˣ', 'At x = 0: f(0) = 1, f''(0) = 1, f''''(0) = 1, ...', 'eˣ = 1 + x + x²/2! + x³/3! + ...', 'First 3 terms: 1 + x + x^2/2'],
  ARRAY['taylor-series', 'power-series', 'expansions', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='taylor-series-expansion'), '', '1 + x + x^2/2', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- PARAMETRIC EQUATIONS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'parametric-derivative',
  'Derivative of Parametric Equations',
  E'For parametric equations $x = x(t)$, $y = y(t)$:\n\n$$\\frac{dy}{dx} = \\frac{dy/dt}{dx/dt}$$\n\n**Problem:** For $x = t^2$ and $y = t^3$, find $\\frac{dy}{dx}$ at $t = 2$.\n\nRound to 1 decimal place.',
  'fill_blank', 'Medium', 'Calculus II', 155,
  ARRAY['dx/dt = 2t', 'dy/dt = 3t²', 'dy/dx = 3t²/(2t) = 3t/2', 'At t = 2: dy/dx = 3(2)/2 = 3'],
  ARRAY['parametric-equations', 'derivatives', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='parametric-derivative'), '', '3.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- CONCEPT PROBLEMS: CALCULUS II
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-series-vs-sequence',
  'Series vs Sequence',
  E'**Question:** What is the difference between a sequence and a series?',
  'multiple_choice', 'Easy', 'Calculus II', 120,
  ARRAY['Sequence: list of numbers', 'Series: sum of sequence terms'],
  ARRAY['sequences', 'series', 'concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-series-vs-sequence'), 'A', 'A sequence is a list of numbers; a series is the sum of the terms of a sequence', true, 0),
((SELECT id FROM problems WHERE slug='concept-series-vs-sequence'), 'B', 'They are the same thing', false, 1),
((SELECT id FROM problems WHERE slug='concept-series-vs-sequence'), 'C', 'A series has only finitely many terms; a sequence can be infinite', false, 2),
((SELECT id FROM problems WHERE slug='concept-series-vs-sequence'), 'D', 'A sequence always converges; a series may diverge', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-p-series',
  'P-Series Convergence Test',
  E'**Question:** The p-series $\\sum_{n=1}^{\\infty} \\frac{1}{n^p}$ converges if and only if:',
  'multiple_choice', 'Medium', 'Calculus II', 140,
  ARRAY['p > 1: converge', 'p ≤ 1: diverge'],
  ARRAY['series', 'convergence-tests', 'p-series', 'concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-p-series'), 'A', 'p > 1', true, 0),
((SELECT id FROM problems WHERE slug='concept-p-series'), 'B', 'p ≤ 1', false, 1),
((SELECT id FROM problems WHERE slug='concept-p-series'), 'C', 'p < 0', false, 2),
((SELECT id FROM problems WHERE slug='concept-p-series'), 'D', 'p = 1', false, 3)
ON CONFLICT DO NOTHING;
