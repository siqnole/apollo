-- ── Add Unit-Level Tags to All STEM Problems ────────────────────────────────
-- Run: psql -U postgres -d apollo -h localhost -f update_stem_tags.sql
-- Adds granular unit-level tags to provide better filtering and discovery

-- ─────────────────────────────────────────────────────────────────────────
-- PHYSICS UNIT-LEVEL TAGS
-- ─────────────────────────────────────────────────────────────────────────

UPDATE problems SET tags = array_append(tags, 'kinematics') 
WHERE slug IN ('kinematics-constant-velocity', 'kinematics-acceleration-time', 
               'kinematics-displacement-acceleration', 'kinematics-velocity-displacement');

UPDATE problems SET tags = array_append(tags, 'dynamics') 
WHERE slug IN ('dynamics-newtons-second-law', 'dynamics-friction-force', 'dynamics-tension-pulley');

UPDATE problems SET tags = array_append(tags, 'circular-motion') 
WHERE slug IN ('circular-centripetal-acceleration', 'circular-centripetal-force', 
               'circular-motion-banking', 'circular-angular-velocity', 'circular-period-frequency');

UPDATE problems SET tags = array_append(tags, 'energy') 
WHERE slug IN ('energy-kinetic', 'energy-potential', 'energy-conservation', 'energy-work');

UPDATE problems SET tags = array_append(tags, 'motion-graphs') 
WHERE slug IN ('motion-graph-interpretation', 'motion-graph-area', 'motion-acceleration-graph');

UPDATE problems SET tags = array_append(tags, 'projectile-motion') 
WHERE slug IN ('projectile-motion-range');

UPDATE problems SET tags = array_append(tags, 'inclined-planes') 
WHERE slug IN ('incline-motion');

UPDATE problems SET tags = array_append(tags, 'centrifugal-force') 
WHERE slug IN ('centrifugal-effect', 'centrifugal-max-speed-curve');

-- ─────────────────────────────────────────────────────────────────────────
-- CHEMISTRY UNIT-LEVEL TAGS
-- ─────────────────────────────────────────────────────────────────────────

UPDATE problems SET tags = array_append(tags, 'isotope-notation') 
WHERE slug IN ('isotope-notation-protons', 'isotope-neutrons', 'isotope-abundance-mass');

UPDATE problems SET tags = array_append(tags, 'molar-mass') 
WHERE slug IN ('molar-mass-simple', 'molar-mass-complex', 'mole-calculation-mass');

UPDATE problems SET tags = array_append(tags, 'avogadros-number') 
WHERE slug IN ('mole-calculation-particles');

UPDATE problems SET tags = array_append(tags, 'molarity-concentration') 
WHERE slug IN ('molarity-definition', 'molarity-from-mass', 'dilution-formula');

UPDATE problems SET tags = array_append(tags, 'chemical-equations') 
WHERE slug IN ('balancing-equations-intro');

UPDATE problems SET tags = array_append(tags, 'stoichiometry-moles') 
WHERE slug IN ('stoichiometry-mole-ratio');

UPDATE problems SET tags = array_append(tags, 'stoichiometry-mass') 
WHERE slug IN ('stoichiometry-mass-conversion');

UPDATE problems SET tags = array_append(tags, 'limiting-reagent') 
WHERE slug IN ('limiting-reagent');

UPDATE problems SET tags = array_append(tags, 'percent-composition') 
WHERE slug IN ('percent-composition');

UPDATE problems SET tags = array_append(tags, 'oxidation-states') 
WHERE slug IN ('oxidation-state-basics', 'redox-identification');

UPDATE problems SET tags = array_append(tags, 'acid-base') 
WHERE slug IN ('pH-calculation', 'pOH-pH-relation', 'neutralization-reaction');

UPDATE problems SET tags = array_append(tags, 'percent-yield') 
WHERE slug IN ('percent-yield');

-- ─────────────────────────────────────────────────────────────────────────
-- CALCULUS I UNIT-LEVEL TAGS
-- ─────────────────────────────────────────────────────────────────────────

UPDATE problems SET tags = array_append(tags, 'limits') 
WHERE slug IN ('limit-direct-substitution', 'limit-indeterminate-form');

UPDATE problems SET tags = array_append(tags, 'derivatives-rules') 
WHERE slug IN ('derivative-power-rule', 'derivative-product-rule', 'derivative-chain-rule');

UPDATE problems SET tags = array_append(tags, 'derivative-applications') 
WHERE slug IN ('critical-points-optimization', 'related-rates');

UPDATE problems SET tags = array_append(tags, 'antiderivatives') 
WHERE slug IN ('antiderivative-power-rule');

UPDATE problems SET tags = array_append(tags, 'definite-integrals') 
WHERE slug IN ('definite-integral-fundamental-theorem');

UPDATE problems SET tags = array_append(tags, 'area-curves') 
WHERE slug IN ('area-between-curves');

-- ─────────────────────────────────────────────────────────────────────────
-- CALCULUS II UNIT-LEVEL TAGS
-- ─────────────────────────────────────────────────────────────────────────

UPDATE problems SET tags = array_append(tags, 'u-substitution') 
WHERE slug IN ('u-substitution');

UPDATE problems SET tags = array_append(tags, 'integration-by-parts') 
WHERE slug IN ('integration-by-parts');

UPDATE problems SET tags = array_append(tags, 'trigonometric-integrals') 
WHERE slug IN ('trigonometric-integral');

UPDATE problems SET tags = array_append(tags, 'improper-integrals') 
WHERE slug IN ('improper-integral-convergence');

UPDATE problems SET tags = array_append(tags, 'sequences') 
WHERE slug IN ('sequence-limit');

UPDATE problems SET tags = array_append(tags, 'geometric-series') 
WHERE slug IN ('geometric-series-sum');

UPDATE problems SET tags = array_append(tags, 'convergence-tests') 
WHERE slug IN ('series-test-divergence');

UPDATE problems SET tags = array_append(tags, 'taylor-series') 
WHERE slug IN ('taylor-series-expansion');

UPDATE problems SET tags = array_append(tags, 'parametric-equations') 
WHERE slug IN ('parametric-derivative');

-- ─────────────────────────────────────────────────────────────────────────
-- CALCULUS III UNIT-LEVEL TAGS
-- ─────────────────────────────────────────────────────────────────────────

UPDATE problems SET tags = array_append(tags, 'partial-derivatives') 
WHERE slug IN ('partial-derivative-first', 'partial-derivative-mixed');

UPDATE problems SET tags = array_append(tags, 'multivariable-optimization') 
WHERE slug IN ('critical-points-2d', 'second-derivative-test');

UPDATE problems SET tags = array_append(tags, 'gradient-vector') 
WHERE slug IN ('gradient-vector', 'directional-derivative');

UPDATE problems SET tags = array_append(tags, 'double-integrals') 
WHERE slug IN ('double-integral-rectangular', 'polar-coordinates-integral');

UPDATE problems SET tags = array_append(tags, 'line-integrals') 
WHERE slug IN ('line-integral-scalar');

-- ─────────────────────────────────────────────────────────────────────────
-- LINEAR ALGEBRA UNIT-LEVEL TAGS
-- ─────────────────────────────────────────────────────────────────────────

UPDATE problems SET tags = array_append(tags, 'matrix-operations') 
WHERE slug IN ('matrix-addition', 'matrix-multiplication', 'matrix-transpose');

UPDATE problems SET tags = array_append(tags, 'determinants') 
WHERE slug IN ('determinant-2x2', 'determinant-3x3');

UPDATE problems SET tags = array_append(tags, 'matrix-inverse') 
WHERE slug IN ('matrix-inverse-2x2');

UPDATE problems SET tags = array_append(tags, 'eigenvalues-eigenvectors') 
WHERE slug IN ('eigenvalue-characteristic-polynomial', 'eigenvector-from-eigenvalue');

UPDATE problems SET tags = array_append(tags, 'linear-systems') 
WHERE slug IN ('linear-system-substitution', 'linear-system-gaussian-elimination');

UPDATE problems SET tags = array_append(tags, 'vector-spaces') 
WHERE slug IN ('linear-independence', 'rank-nullity-theorem');

-- ─────────────────────────────────────────────────────────────────────────
-- DIFFERENTIAL EQUATIONS UNIT-LEVEL TAGS
-- ─────────────────────────────────────────────────────────────────────────

UPDATE problems SET tags = array_append(tags, 'separable-ode') 
WHERE slug IN ('separable-equation-basic', 'exponential-growth-decay');

UPDATE problems SET tags = array_append(tags, 'linear-ode') 
WHERE slug IN ('linear-first-order-ode');

UPDATE problems SET tags = array_append(tags, 'second-order-ode') 
WHERE slug IN ('homogeneous-second-order', 'nonhomogeneous-undetermined-coefficients');

UPDATE problems SET tags = array_append(tags, 'systems-ode') 
WHERE slug IN ('system-linear-ode');

UPDATE problems SET tags = array_append(tags, 'laplace-transform') 
WHERE slug IN ('laplace-transform-basic', 'laplace-solve-ode');

UPDATE problems SET tags = array_append(tags, 'qualitative-analysis') 
WHERE slug IN ('equilibrium-stability');

-- ─────────────────────────────────────────────────────────────────────────
-- Verification: Count updated problems
-- ─────────────────────────────────────────────────────────────────────────

SELECT 
  category,
  COUNT(*) as problem_count,
  COUNT(DISTINCT slug) as unique_problems
FROM problems
WHERE category IN ('Physics', 'Chemistry', 'Calculus I', 'Calculus II', 'Calculus III', 'Linear Algebra', 'Differential Equations')
GROUP BY category
ORDER BY category;
