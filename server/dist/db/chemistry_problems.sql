-- ── Chemistry Problems: Stoichiometry, Molarity, Isotopes & More ──────────
-- Run: psql -U postgres -d apollo -h localhost -f chemistry_problems.sql
-- Requires LaTeX rendering (KaTeX) in the frontend for equations.

-- ─────────────────────────────────────────────────────────────────────────
-- ISOTOPES & ATOMIC STRUCTURE
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'isotope-notation-protons',
  'Isotope Notation and Protons',
  E'Isotopes are atoms of the same element with different numbers of neutrons. Isotope notation is written as:\n\n$$^A_Z X$$\n\nwhere:\n- $A$ = mass number (protons + neutrons)\n- $Z$ = atomic number (number of protons)\n- $X$ = element symbol\n\n**Problem:** Write the isotope notation for Oxygen with 8 protons and 9 neutrons.\n\nFormat: ^A_Z X (e.g., ^16_8 O)',
  'fill_blank', 'Easy', 'Chemistry', 85,
  ARRAY['Mass number A = protons + neutrons = 8 + 9 = 17', 'Atomic number Z = 8 for oxygen', 'Notation: ^17_8 O'],
  ARRAY['isotopes', 'atomic-structure', 'notation', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='isotope-notation-protons'), '', '^17_8 O', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'isotope-neutrons',
  'Calculate Number of Neutrons in an Isotope',
  E'The number of neutrons in an atom is calculated as:\n\n$$\\text{Number of neutrons} = A - Z$$\n\nwhere:\n- $A$ = mass number\n- $Z$ = atomic number (number of protons)\n\n**Problem:** For the isotope Carbon-14 ($^{14}_6 C$), how many neutrons are present?\n\nProvide just the number.',
  'fill_blank', 'Easy', 'Chemistry', 80,
  ARRAY['Mass number A = 14', 'Atomic number Z = 6', 'Neutrons = 14 - 6'],
  ARRAY['isotopes', 'atomic-structure', 'neutrons', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='isotope-neutrons'), '', '8', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'isotope-abundance-mass',
  'Average Atomic Mass from Isotope Abundance',
  E'When an element exists as multiple isotopes, the average atomic mass is:\n\n$$M_{{avg}} = \\sum (\\text{mass}_i \\times \\text{abundance}_i)$$\n\nwhere abundances are expressed as decimals (sum to 1.0).\n\n**Problem:** Chlorine has two main isotopes:\n- $^{35}_{17}$Cl: mass = 34.97 u, abundance = 75.77%\n- $^{37}_{17}$Cl: mass = 36.97 u, abundance = 24.23%\n\nCalculate the average atomic mass of chlorine.\n\nRound to 2 decimal places.',
  'fill_blank', 'Medium', 'Chemistry', 115,
  ARRAY['Convert percentages to decimals: 0.7577 and 0.2423', 'M_avg = (34.97 × 0.7577) + (36.97 × 0.2423)', 'M_avg = 26.50 + 8.96'],
  ARRAY['isotopes', 'atomic-mass', 'abundance', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='isotope-abundance-mass'), '', '35.46', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- MOLAR MASS & MOLES
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'molar-mass-simple',
  'Calculate Molar Mass of a Compound',
  E'The molar mass (M) of a compound is the sum of atomic masses of all atoms in the formula, in g/mol.\n\n**Problem:** Calculate the molar mass of H₂O (water).\n\nUse:\n- H: 1.01 g/mol\n- O: 16.00 g/mol\n\nProvide your answer rounded to 2 decimal places in g/mol.',
  'fill_blank', 'Easy', 'Chemistry', 90,
  ARRAY['H₂O has 2 hydrogen atoms and 1 oxygen atom', 'M = 2(1.01) + 16.00', 'M = 2.02 + 16.00'],
  ARRAY['molar-mass', 'stoichiometry', 'moles', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='molar-mass-simple'), '', '18.02', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'molar-mass-complex',
  'Molar Mass of Complex Compound',
  E'Calculate the molar mass of Ca(OH)₂ (calcium hydroxide).\n\nUse:\n- Ca: 40.08 g/mol\n- O: 16.00 g/mol\n- H: 1.01 g/mol\n\nNote: The subscript 2 outside the parentheses means 2 OH groups.\n\nProvide your answer in g/mol, rounded to 2 decimal places.',
  'fill_blank', 'Easy', 'Chemistry', 95,
  ARRAY['Ca(OH)₂ = 1 Ca + 2 O + 2 H', 'M = 40.08 + 2(16.00) + 2(1.01)', 'M = 40.08 + 32.00 + 2.02'],
  ARRAY['molar-mass', 'stoichiometry', 'compounds', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='molar-mass-complex'), '', '74.10', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'mole-calculation-mass',
  'Moles from Mass',
  E'The number of moles (n) is calculated from mass and molar mass:\n\n$$n = \\frac{m}{M}$$\n\nwhere:\n- $n$ = number of moles (mol)\n- $m$ = mass (grams)\n- $M$ = molar mass (g/mol)\n\n**Problem:** How many moles are in 36 grams of H₂O? (Molar mass of H₂O = 18 g/mol)\n\nProvide your answer in moles.',
  'fill_blank', 'Easy', 'Chemistry', 100,
  ARRAY['Use n = m / M', 'n = 36 / 18'],
  ARRAY['moles', 'molar-mass', 'stoichiometry', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='mole-calculation-mass'), '', '2', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'mole-calculation-particles',
  'Moles to Particles (Avogadro''s Number)',
  E'Avogadro''s number relates moles to particles:\n\n$$N = n \\times N_A$$\n\nwhere:\n- $N$ = number of particles (atoms, molecules, ions)\n- $n$ = number of moles\n- $N_A$ = Avogadro''s number = $6.022 \\times 10^{23}$ particles/mol\n\n**Problem:** How many water molecules are in 0.5 moles of H₂O?\n\nExpress in scientific notation with 3 significant figures (e.g., 1.23e23).',
  'fill_blank', 'Easy', 'Chemistry', 105,
  ARRAY['N = n × N_A', 'N = 0.5 × 6.022 × 10²³', 'N = 3.011 × 10²³'],
  ARRAY['moles', 'avogadros-number', 'particles', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='mole-calculation-particles'), '', '3.01e23', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- MOLARITY & SOLUTIONS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'molarity-definition',
  'Molarity: Moles per Liter',
  E'Molarity (M) is the concentration of a solution defined as:\n\n$$M = \\frac{\\text{moles of solute}}{\\text{liters of solution}}$$\n\nor:\n\n$$M = \\frac{n}{V}$$\n\n**Problem:** If 2.5 moles of NaCl are dissolved in enough water to make 0.5 liters of solution, what is the molarity?\n\nProvide your answer in M (mol/L).',
  'fill_blank', 'Easy', 'Chemistry', 100,
  ARRAY['M = n / V', 'M = 2.5 / 0.5'],
  ARRAY['molarity', 'concentration', 'solution', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='molarity-definition'), '', '5', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'molarity-from-mass',
  'Calculate Molarity from Mass',
  E'To find molarity from a mass of solute:\n\n$$M = \\frac{m / M_{\\text{molar}}}{V}$$\n\nwhere:\n- $m$ = mass of solute (g)\n- $M_{\\text{molar}}$ = molar mass (g/mol)\n- $V$ = volume of solution (L)\n\n**Problem:** If 5.85 grams of NaCl are dissolved in 250 mL of solution, what is the molarity? (Molar mass of NaCl = 58.5 g/mol)\n\nRound to 2 decimal places.',
  'fill_blank', 'Medium', 'Chemistry', 120,
  ARRAY['First calculate moles: n = 5.85 / 58.5 = 0.1 mol', 'Convert volume: 250 mL = 0.25 L', 'M = 0.1 / 0.25 = 0.4 M'],
  ARRAY['molarity', 'concentration', 'molar-mass', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='molarity-from-mass'), '', '0.40', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'dilution-formula',
  'Dilution Formula: M₁V₁ = M₂V₂',
  E'When diluting a solution, the number of moles of solute stays constant:\n\n$$M_1 V_1 = M_2 V_2$$\n\nwhere:\n- $M_1$ = initial molarity\n- $V_1$ = initial volume\n- $M_2$ = final molarity\n- $V_2$ = final volume\n\n**Problem:** You have 100 mL of 2.0 M HCl solution. You dilute it to 500 mL by adding water. What is the final molarity?\n\nRound to 2 decimal places.',
  'fill_blank', 'Medium', 'Chemistry', 125,
  ARRAY['M₁V₁ = M₂V₂', '2.0 × 100 = M₂ × 500', 'M₂ = 200 / 500'],
  ARRAY['molarity', 'dilution', 'concentration', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='dilution-formula'), '', '0.40', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- STOICHIOMETRY & CHEMICAL REACTIONS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'balancing-equations-intro',
  'Balance Chemical Equation: Simple Combustion',
  E'To balance a chemical equation, adjust coefficients so the number of each atom is equal on both sides.\n\n**Unbalanced:** CH₄ + O₂ → CO₂ + H₂O\n\n**Problem:** What is the correct balanced equation? Write the coefficients in order: a CH₄ + b O₂ → c CO₂ + d H₂O\n\nFormat: a b c d (e.g., 1 2 1 2)',
  'fill_blank', 'Easy', 'Chemistry', 105,
  ARRAY['C atoms: 1 on left, 1 on right ✓', 'H atoms: 4 on left, need 4 on right → 2 H₂O', 'O atoms: 4 on right, need 4 on left → 2 O₂', 'Balanced: 1 CH₄ + 2 O₂ → 1 CO₂ + 2 H₂O'],
  ARRAY['balancing', 'equations', 'stoichiometry', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='balancing-equations-intro'), '', '1 2 1 2', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'stoichiometry-mole-ratio',
  'Stoichiometry: Mole-to-Mole Calculations',
  E'Stoichiometry uses balanced equation coefficients to convert between moles of reactants and products.\n\n**Reaction:** 2 H₂ + O₂ → 2 H₂O\n\n**Problem:** If 4 moles of H₂ react completely, how many moles of H₂O are produced?\n\nProvide your answer in moles.',
  'fill_blank', 'Medium', 'Chemistry', 120,
  ARRAY['From the balanced equation: 2 mol H₂ : 2 mol H₂O (ratio 1:1)', 'If 4 mol H₂ reacts, then (4 mol H₂) × (2 mol H₂O / 2 mol H₂)'],
  ARRAY['stoichiometry', 'mole-ratios', 'reactions', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='stoichiometry-mole-ratio'), '', '4', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'stoichiometry-mass-conversion',
  'Stoichiometry: Mass-to-Mass Calculation',
  E'To convert between masses of different substances in a reaction:\n\n$$m_2 = m_1 \\times \\frac{M_1}{M_2} \\times \\frac{\\text{coeff}_2}{\\text{coeff}_1}$$\n\n**Reaction:** Mg + 2 HCl → MgCl₂ + H₂\n\n**Problem:** If 24 grams of Mg react, how many grams of H₂ are produced?\n\nUse:\n- Molar mass Mg = 24 g/mol\n- Molar mass H₂ = 2 g/mol\n\nRound to 1 decimal place.',
  'fill_blank', 'Hard', 'Chemistry', 140,
  ARRAY['Moles of Mg = 24 / 24 = 1 mol', 'From equation: 1 Mg : 1 H₂', 'Moles of H₂ = 1 mol', 'Mass of H₂ = 1 × 2 = 2 g'],
  ARRAY['stoichiometry', 'mass-mass', 'chemical-reactions', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='stoichiometry-mass-conversion'), '', '2.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'limiting-reagent',
  'Limiting Reagent Problem',
  E'The limiting reagent is the reactant that is completely consumed, determining how much product forms.\n\n**Reaction:** 2 H₂ + O₂ → 2 H₂O\n\n**Problem:** If 4 moles of H₂ and 2 moles of O₂ are available, which is the limiting reagent?\n\nAnswer with the formula (H₂ or O₂).',
  'fill_blank', 'Medium', 'Chemistry', 130,
  ARRAY['From equation: 2 H₂ : 1 O₂ (2:1 ratio)', 'Available: 4 H₂ : 2 O₂', 'If 4 H₂ reacts, need 2 O₂ (have exactly 2 O₂)', 'If 2 O₂ reacts, need 4 H₂ (have exactly 4 H₂)', 'Either could work; check: O₂ would need 4 H₂ per 2 O₂. We have exactly that.', 'Actually, with 4:2 vs needed 2:1, we have equal amounts. Both are OR consider: H₂/O₂ = 4/2 = 2, stoich ratio = 2/1 = 2. Equal! But typically one is limiting.'],
  ARRAY['limiting-reagent', 'stoichiometry', 'reactions', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='limiting-reagent'), '', 'neither', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- PERCENT COMPOSITION
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'percent-composition',
  'Percent Composition of an Element',
  E'Percent composition shows what percentage of a compound''s mass comes from each element:\n\n$$\\% \\text{ composition} = \\frac{(\\text{atoms} \\times \\text{atomic mass})}{\\text{molar mass}} \\times 100\\%$$\n\n**Problem:** Calculate the percent composition of carbon in CO₂.\n\nUse:\n- C: 12 g/mol\n- O: 16 g/mol\n- Molar mass CO₂ = 44 g/mol\n\nRound to 1 decimal place.',
  'fill_blank', 'Medium', 'Chemistry', 125,
  ARRAY['CO₂ has 1 carbon and 2 oxygen atoms', 'Mass of C in CO₂ = 1 × 12 = 12 g', '% C = (12 / 44) × 100%'],
  ARRAY['percent-composition', 'stoichiometry', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='percent-composition'), '', '27.3', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- OXIDATION STATES
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'oxidation-state-basics',
  'Assign Oxidation States: Neutral Molecule',
  E'Oxidation state rules:\n- Atoms in elemental form: 0\n- Monoatomic ions: charge of ion\n- Oxygen (usually): -2\n- Hydrogen (usually): +1\n- Sum in neutral compound: 0\n- Sum in polyatomic ion: charge\n\n**Problem:** Assign oxidation states to each element in H₂SO₄.\n\nFormat: H S O (separated by spaces, e.g., +1 +6 -2)',
  'fill_blank', 'Medium', 'Chemistry', 120,
  ARRAY['H is +1, O is -2', 'Let S be x: 2(+1) + x + 4(-2) = 0', '+2 + x - 8 = 0, so x = +6', 'Answer: +1 +6 -2'],
  ARRAY['oxidation-states', 'redox', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='oxidation-state-basics'), '', '+1 +6 -2', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'redox-identification',
  'Identify Redox Reaction Type',
  E'In redox reactions, oxidation state changes identify electron transfer:\n- **Oxidation:** loss of electrons (oxidation state increases)\n- **Reduction:** gain of electrons (oxidation state decreases)\n\n**Reaction:** 2 Mg + O₂ → 2 MgO\n\n**Question:** What is the oxidation state change for Mg?\n\nFormat: initial final (e.g., 0 +2)',
  'fill_blank', 'Medium', 'Chemistry', 125,
  ARRAY['Mg in elemental form: 0', 'Mg in MgO (ionic): +2', 'Change: 0 → +2 (oxidation, loses 2 electrons)'],
  ARRAY['redox', 'oxidation-states', 'reactions', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='redox-identification'), '', '0 +2', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- ACID-BASE CHEMISTRY
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'pH-calculation',
  'Calculate pH from [H⁺]',
  E'pH is defined as:\n\n$$\\text{pH} = -\\log_{10}[H^+]$$\n\nwhere $[H^+]$ is the molar concentration of hydrogen ions.\n\n**Problem:** A solution has $[H^+] = 1 \\times 10^{-4}$ M. What is the pH?\n\nProvide your answer as a whole number.',
  'fill_blank', 'Medium', 'Chemistry', 120,
  ARRAY['pH = -log(1 × 10⁻⁴)', 'pH = -(-4) = 4'],
  ARRAY['pH', 'acid-base', 'logarithms', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='pH-calculation'), '', '4', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'pOH-pH-relation',
  'Relationship between pH and pOH',
  E'At 25°C, the water ion product is constant:\n\n$$\\text{pH} + \\text{pOH} = 14$$\n\nwhere:\n- $\\text{pH} = -\\log[H^+]$\n- $\\text{pOH} = -\\log[OH^-]$\n\n**Problem:** A solution has pH = 11. What is the pOH?\n\nProvide your answer as a whole number.',
  'fill_blank', 'Easy', 'Chemistry', 110,
  ARRAY['pH + pOH = 14', '11 + pOH = 14', 'pOH = 3'],
  ARRAY['pH', 'pOH', 'acid-base', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='pOH-pH-relation'), '', '3', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'neutralization-reaction',
  'Acid-Base Neutralization',
  E'In a neutralization reaction:\n\n$$\\text{Acid} + \\text{Base} \\rightarrow \\text{Salt} + \\text{Water}$$\n\nMoles of acid = Moles of base (for monoprotic acids and monobasic bases)\n\n**Problem:** 50 mL of 0.20 M HCl is titrated with NaOH. How many moles of HCl are present?\n\nRound to 2 decimal places.',
  'fill_blank', 'Easy', 'Chemistry', 115,
  ARRAY['Volume must be in liters: 50 mL = 0.050 L', 'Moles = M × V = 0.20 × 0.050'],
  ARRAY['neutralization', 'acid-base', 'molarity', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='neutralization-reaction'), '', '0.01', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- THEORETICAL VS PERCENT YIELD
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'percent-yield',
  'Calculate Percent Yield',
  E'Percent yield compares actual product to theoretical (calculated) product:\n\n$$\\% \\text{ yield} = \\frac{\\text{actual yield}}{\\text{theoretical yield}} \\times 100\\%$$\n\n**Problem:** A reaction theoretically produces 25 grams of product, but only 18 grams are actually obtained. What is the percent yield?\n\nRound to 1 decimal place.',
  'fill_blank', 'Medium', 'Chemistry', 130,
  ARRAY['% yield = (actual / theoretical) × 100%', '% yield = (18 / 25) × 100%', '% yield = 0.72 × 100%'],
  ARRAY['yield', 'stoichiometry', 'reactions', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='percent-yield'), '', '72.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- MULTIPLE CHOICE CONCEPT PROBLEMS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-element-vs-compound',
  'Distinguish Element from Compound',
  E'**Question:** Which of the following is a pure element (not a compound)?',
  'multiple_choice', 'Easy', 'Chemistry', 85,
  ARRAY['Elements have one type of atom', 'Compounds have two or more elements bonded together'],
  ARRAY['elements', 'compounds', 'matter', 'chemistry-concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-element-vs-compound'), 'A', 'O₂ (oxygen gas)', true, 0),
((SELECT id FROM problems WHERE slug='concept-element-vs-compound'), 'B', 'H₂O (water)', false, 1),
((SELECT id FROM problems WHERE slug='concept-element-vs-compound'), 'C', 'NaCl (salt)', false, 2),
((SELECT id FROM problems WHERE slug='concept-element-vs-compound'), 'D', 'CO₂ (carbon dioxide)', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-mole-definition',
  'What is a Mole?',
  E'**Question:** Which statement best describes a mole in chemistry?',
  'multiple_choice', 'Easy', 'Chemistry', 95,
  ARRAY['Think: 1 mole = 6.022 × 10²³ particles', 'Molar mass in grams = mass of 1 mole'],
  ARRAY['moles', 'avogadros-number', 'stoichiometry', 'chemistry-concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-mole-definition'), 'A', 'A unit of mass equal to the atomic number', false, 0),
((SELECT id FROM problems WHERE slug='concept-mole-definition'), 'B', 'A unit of amount containing 6.022 × 10²³ particles', true, 1),
((SELECT id FROM problems WHERE slug='concept-mole-definition'), 'C', 'The volume of gas at STP', false, 2),
((SELECT id FROM problems WHERE slug='concept-mole-definition'), 'D', 'The density of a substance', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-isotopes-definition',
  'Understanding Isotopes',
  E'**Question:** What defines two isotopes of the same element?',
  'multiple_choice', 'Easy', 'Chemistry', 90,
  ARRAY['Isotopes are atoms of the same element', 'They differ in neutrons, not protons'],
  ARRAY['isotopes', 'atomic-structure', 'chemistry-concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-isotopes-definition'), 'A', 'Same number of protons, different number of neutrons', true, 0),
((SELECT id FROM problems WHERE slug='concept-isotopes-definition'), 'B', 'Same number of protons and neutrons, different electrons', false, 1),
((SELECT id FROM problems WHERE slug='concept-isotopes-definition'), 'C', 'Different number of protons but same mass number', false, 2),
((SELECT id FROM problems WHERE slug='concept-isotopes-definition'), 'D', 'Atoms in different physical states', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-molarity-vs-molality',
  'Molarity vs Other Concentration Units',
  E'**Question:** Molarity is defined as moles of solute per _____ of solution.',
  'multiple_choice', 'Easy', 'Chemistry', 100,
  ARRAY['Molarity uses volume', 'The symbol M stands for mol/L'],
  ARRAY['molarity', 'concentration', 'units', 'chemistry-concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-molarity-vs-molality'), 'A', 'kilogram of solvent', false, 0),
((SELECT id FROM problems WHERE slug='concept-molarity-vs-molality'), 'B', 'liter of solution', true, 1),
((SELECT id FROM problems WHERE slug='concept-molarity-vs-molality'), 'C', 'mole of solute', false, 2),
((SELECT id FROM problems WHERE slug='concept-molarity-vs-molality'), 'D', 'gram of compound', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- SHORT ANSWER PROBLEMS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'explain-isotope-mass-difference',
  'Explain Why Isotopes Have Different Masses',
  E'**Question:** Isotopes of the same element have different mass numbers. Explain why.',
  'short_answer', 'Medium', 'Chemistry', 120,
  ARRAY['Both have the same protons', 'Mass number = protons + neutrons'],
  ARRAY['isotopes', 'mass-number', 'atomic-structure', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='explain-isotope-mass-difference'), '', 'Isotopes have different numbers of neutrons, and mass number = protons + neutrons, so different neutrons = different mass numbers', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'explain-mole-utility',
  'Why Chemists Use the Mole',
  E'**Question:** Explain why the mole is useful for chemists relating macroscopic (observable) measurements to microscopic (atomic) scales.',
  'short_answer', 'Hard', 'Chemistry', 135,
  ARRAY['Molar mass connects observable grams to number of atoms', '1 mole = molar mass in grams = 6.022 × 10²³ particles'],
  ARRAY['moles', 'stoichiometry', 'avogadros-number', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='explain-mole-utility'), '', 'The mole allows conversion between grams (observable) and number of atoms/molecules (microscopic); molar mass numerically equals g/mol', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'explain-limiting-reagent-importance',
  'Limiting Reagent in Real-World Chemistry',
  E'**Question:** In a real chemical reaction with two reactants, why is identifying the limiting reagent important?',
  'short_answer', 'Hard', 'Chemistry', 140,
  ARRAY['One reactant is completely consumed', 'It determines maximum product amount'],
  ARRAY['limiting-reagent', 'stoichiometry', 'reactions', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='explain-limiting-reagent-importance'), '', 'The limiting reagent is completely consumed and determines the maximum amount of product that can form', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- CHALLENGING INTEGRATED PROBLEMS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'integrated-isotope-abundance-molarity',
  'Combined: Isotope Abundances and Molarity',
  E'An element has two isotopes with average atomic mass 35.45 u. A 250 mL solution containing 1.75 g of this element (as a salt) has molarity 0.1 M.\n\n**Problem:** Calculate the molar mass of the salt if it contains one atom of the element per formula unit.\n\nRound to 1 decimal place in g/mol.',
  'fill_blank', 'Expert', 'Chemistry', 180,
  ARRAY['Element atomic mass = 35.45 g/mol', 'Moles in solution = 0.1 M × 0.25 L = 0.025 mol', 'If 0.025 mol of salt from 1.75 g:', 'Molar mass = 1.75 / 0.025 = 70 g/mol'],
  ARRAY['isotopes', 'molarity', 'molar-mass', 'integrated', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='integrated-isotope-abundance-molarity'), '', '70.0', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'integrated-stoichiometry-limiting-reagent-yield',
  'Stoichiometry with Limiting Reagent and Yield',
  E'**Reaction:** 2 Fe + 3 Cl₂ → 2 FeCl₃\n\nYou react 55.8 g Fe (molar mass 55.8 g/mol) with 71 g Cl₂ (molar mass 71 g/mol).\n\n**Problem:** If the percent yield is 80%, how many grams of FeCl₃ are actually produced (molar mass 162.5 g/mol)?\n\nRound to 1 decimal place.',
  'fill_blank', 'Expert', 'Chemistry', 185,
  ARRAY['Moles Fe = 55.8 / 55.8 = 1 mol', 'Moles Cl₂ = 71 / 71 = 1 mol', 'Stoich ratio Fe:Cl₂ = 2:3; need 1.5 mol Cl₂ for 1 mol Fe', 'Only have 1 mol Cl₂, so Cl₂ is limiting', 'From 1 mol Cl₂: produces (2/3) mol FeCl₃ = 0.667 mol', 'Theoretical: 0.667 × 162.5 = 108.3 g', 'Actual (80%): 108.3 × 0.80 = 86.6 g'],
  ARRAY['stoichiometry', 'limiting-reagent', 'percent-yield', 'integrated', 'chemistry'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='integrated-stoichiometry-limiting-reagent-yield'), '', '88.7', false, 0)
ON CONFLICT DO NOTHING;
