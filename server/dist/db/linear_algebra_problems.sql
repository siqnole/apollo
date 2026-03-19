-- ── Linear Algebra: Matrices, Eigenvalues, Vector Spaces ───────────────────
-- Run: psql -U postgres -d apollo -h localhost -f linear_algebra_problems.sql
-- Requires LaTeX rendering (KaTeX) in the frontend.

-- ─────────────────────────────────────────────────────────────────────────
-- MATRIX OPERATIONS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'matrix-addition',
  'Matrix Addition',
  E'Matrix addition is performed element-wise:\n\n$$[A + B]_{ij} = a_{ij} + b_{ij}$$\n\n**Problem:** Compute $A + B$ where:\n\n$$A = \\begin{pmatrix} 1 & 2 \\\\ 3 & 4 \\end{pmatrix}, \\quad B = \\begin{pmatrix} 5 & 6 \\\\ 7 & 8 \\end{pmatrix}$$\n\nFormat: (1,1) entry, (1,2) entry; (2,1) entry, (2,2) entry (e.g., 6, 8; 10, 12)',
  'fill_blank', 'Easy', 'Linear Algebra', 110,
  ARRAY['Add corresponding elements', '1+5=6, 2+6=8, 3+7=10, 4+8=12'],
  ARRAY['matrices', 'matrix-operations', 'linear-algebra'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='matrix-addition'), '', '6, 8; 10, 12', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'matrix-multiplication',
  'Matrix Multiplication',
  E'For matrices $A$ ($m \\times n$) and $B$ ($n \\times p$), the product $AB$ is $m \\times p$:\n\n$$[AB]_{ij} = \\sum_{k=1}^{n} a_{ik} b_{kj}$$\n\n**Problem:** Compute $AB$ where:\n\n$$A = \\begin{pmatrix} 1 & 2 \\\\ 3 & 4 \\end{pmatrix}, \\quad B = \\begin{pmatrix} 2 \\\\ 3 \\end{pmatrix}$$\n\nFormat: (1,1), (2,1) (e.g., 8, 18)',
  'fill_blank', 'Easy', 'Linear Algebra', 120,
  ARRAY['(1,1): 1(2) + 2(3) = 2 + 6 = 8', '(2,1): 3(2) + 4(3) = 6 + 12 = 18'],
  ARRAY['matrices', 'matrix-multiplication', 'linear-algebra'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='matrix-multiplication'), '', '8, 18', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'matrix-transpose',
  'Matrix Transpose',
  E'The transpose of matrix $A$, denoted $A^T$ or $A''$, swaps rows and columns:\n\n$$(A^T)_{ij} = a_{ji}$$\n\n**Problem:** Find $A^T$ where:\n\n$$A = \\begin{pmatrix} 1 & 2 & 3 \\\\ 4 & 5 & 6 \\end{pmatrix}$$\n\nFormat: row 1; row 2; row 3 (e.g., 1, 4; 2, 5; 3, 6)',
  'fill_blank', 'Easy', 'Linear Algebra', 105,
  ARRAY['Row 1 of A becomes column 1 of Aᵀ', '1, 4; 2, 5; 3, 6'],
  ARRAY['matrices', 'transpose', 'linear-algebra'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='matrix-transpose'), '', '1, 4; 2, 5; 3, 6', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- DETERMINANTS & INVERSES
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'determinant-2x2',
  'Determinant of 2×2 Matrix',
  E'For a $2 \\times 2$ matrix:\n\n$$\\det(A) = \\det\\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix} = ad - bc$$\n\n**Problem:** Compute $\\det(A)$ where:\n\n$$A = \\begin{pmatrix} 4 & 2 \\\\ 3 & 1 \\end{pmatrix}$$\n\nProvide as integer.',
  'fill_blank', 'Easy', 'Linear Algebra', 115,
  ARRAY['det(A) = 4(1) - 2(3) = 4 - 6'],
  ARRAY['determinants', 'matrices', 'linear-algebra'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='determinant-2x2'), '', '-2', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'determinant-3x3',
  'Determinant of 3×3 Matrix (Cofactor Expansion)',
  E'For a $3 \\times 3$ matrix, expand along the first row:\n\n$$\\det(A) = a_{11}(a_{22}a_{33} - a_{23}a_{32}) - a_{12}(a_{21}a_{33} - a_{23}a_{31}) + a_{13}(a_{21}a_{32} - a_{22}a_{31})$$\n\n**Problem:** Compute $\\det(A)$ where:\n\n$$A = \\begin{pmatrix} 1 & 0 & 2 \\\\ -1 & 3 & 1 \\\\ 2 & 1 & 0 \\end{pmatrix}$$\n\nProvide as integer.',
  'fill_blank', 'Medium', 'Linear Algebra', 140,
  ARRAY['Expand along row 1', '= 1·(3·0 - 1·1) - 0·(...) + 2·(-1·1 - 3·2)', '= 1(-1) + 2(-1 - 6)', '= -1 + 2(-7) = -1 - 14 = -15'],
  ARRAY['determinants', 'cofactor-expansion', 'linear-algebra'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='determinant-3x3'), '', '-15', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'matrix-inverse-2x2',
  'Inverse of 2×2 Matrix',
  E'For invertible $2 \\times 2$ matrix:\n\n$$A^{-1} = \\frac{1}{\\det(A)} \\begin{pmatrix} d & -b \\\\ -c & a \\end{pmatrix}$$\n\nwhere $A = \\begin{pmatrix} a & b \\\\ c & d \\end{pmatrix}$ and $\\det(A) \\neq 0$\n\n**Problem:** Find $A^{-1}$ where:\n\n$$A = \\begin{pmatrix} 2 & 1 \\\\ 1 & 1 \\end{pmatrix}$$\n\nFormat: (1,1), (1,2); (2,1), (2,2) (e.g., 1, -1; -1, 2)',
  'fill_blank', 'Medium', 'Linear Algebra', 150,
  ARRAY['det(A) = 2(1) - 1(1) = 1', 'A⁻¹ = (1/1)[[1, -1], [-1, 2]] = [[1, -1], [-1, 2]]'],
  ARRAY['matrices', 'matrix-inverse', 'linear-algebra'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='matrix-inverse-2x2'), '', '1, -1; -1, 2', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- EIGENVALUES & EIGENVECTORS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'eigenvalue-characteristic-polynomial',
  'Find Eigenvalues via Characteristic Polynomial',
  E'Eigenvalues are found by solving:\n\n$$\\det(A - \\lambda I) = 0$$\n\nwhere $\\lambda$ is an eigenvalue.\n\n**Problem:** Find the eigenvalues of:\n\n$$A = \\begin{pmatrix} 3 & 0 \\\\ 0 & 2 \\end{pmatrix}$$\n\nFormat: λ₁, λ₂ (e.g., 3, 2)',
  'fill_blank', 'Easy', 'Linear Algebra', 135,
  ARRAY['det(A - λI) = det[[3-λ, 0], [0, 2-λ]]', '= (3-λ)(2-λ) = 0', 'Eigenvalues: λ = 3, 2'],
  ARRAY['eigenvalues', 'characteristic-polynomial', 'linear-algebra'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='eigenvalue-characteristic-polynomial'), '', '3, 2', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'eigenvector-from-eigenvalue',
  'Find Eigenvector from Eigenvalue',
  E'For eigenvalue $\\lambda$, an eigenvector $\\mathbf{v}$ satisfies:\n\n$$(A - \\lambda I)\\mathbf{v} = \\mathbf{0}$$\n\n**Problem:** For $A = \\begin{pmatrix} 2 & 1 \\\\ 1 & 2 \\end{pmatrix}$ and $\\lambda = 3$, find an eigenvector.\n\nFormat: (v1, v2) normalized (e.g., (1, 1))',
  'fill_blank', 'Medium', 'Linear Algebra', 155,
  ARRAY['A - 3I = [[-1, 1], [1, -1]]', 'Solve: -x + y = 0 → y = x', 'Eigenvector: (1, 1) or any scalar multiple'],
  ARRAY['eigenvectors', 'eigenvalues', 'linear-algebra'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='eigenvector-from-eigenvalue'), '', '(1, 1)', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- LINEAR SYSTEMS
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'linear-system-substitution',
  'Solve Linear System by Substitution',
  E'**Problem:** Solve the system:\n\n$$\\begin{cases} 2x + y = 5 \\\\ x - y = 1 \\end{cases}$$\n\nFormat: (x, y) (e.g., (2, 1))',
  'fill_blank', 'Easy', 'Linear Algebra', 125,
  ARRAY['From equation 2: x = y + 1', 'Substitute into equation 1: 2(y+1) + y = 5', '3y + 2 = 5 → y = 1', 'x = 1 + 1 = 2'],
  ARRAY['linear-systems', 'substitution', 'linear-algebra'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='linear-system-substitution'), '', '(2, 1)', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'linear-system-gaussian-elimination',
  'Solve Linear System by Gaussian Elimination',
  E'**Problem:** Solve the system using row reduction:\n\n$$\\begin{cases} x + 2y = 5 \\\\ 3x - y = 4 \\end{cases}$$\n\nFormat: (x, y)',
  'fill_blank', 'Medium', 'Linear Algebra', 145,
  ARRAY['Matrix form: [1, 2 | 5; 3, -1 | 4]', 'R2 - 3R1: [1, 2 | 5; 0, -7 | -11]', '7y = 11 → y = 11/7', 'x = 5 - 2(11/7) = 35/7 - 22/7 = 13/7'],
  ARRAY['linear-systems', 'gaussian-elimination', 'row-reduction', 'linear-algebra'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='linear-system-gaussian-elimination'), '', '(13/7, 11/7)', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- VECTOR SPACES & LINEAR INDEPENDENCE
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'linear-independence',
  'Test Linear Independence',
  E'Vectors $\\mathbf{v}_1, \\mathbf{v}_2, \\ldots, \\mathbf{v}_n$ are linearly independent if:\n\n$$c_1\\mathbf{v}_1 + c_2\\mathbf{v}_2 + \\cdots + c_n\\mathbf{v}_n = \\mathbf{0} \\implies c_1 = c_2 = \\cdots = c_n = 0$$\n\n**Problem:** Are the vectors $\\mathbf{v}_1 = (1, 2)$ and $\\mathbf{v}_2 = (2, 4)$ linearly independent?\n\nAnswer: yes or no',
  'fill_blank', 'Easy', 'Linear Algebra', 130,
  ARRAY['Note: v₂ = 2v₁', 'So v₂ - 2v₁ = 0 with non-zero coefficients', 'They are linearly dependent'],
  ARRAY['linear-independence', 'vector-spaces', 'linear-algebra'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='linear-independence'), '', 'no', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'rank-nullity-theorem',
  'Rank-Nullity Theorem',
  E'For an $m \\times n$ matrix $A$:\n\n$$\\text{rank}(A) + \\text{nullity}(A) = n$$\n\nwhere nullity(A) = dimension of null space = dim(null(A))\n\n**Problem:** An $3 \\times 5$ matrix $A$ has rank 3. What is the nullity?\n\nProvide as integer.',
  'fill_blank', 'Medium', 'Linear Algebra', 145,
  ARRAY['n = 5 (number of columns)', 'rank(A) + nullity(A) = 5', '3 + nullity(A) = 5', 'nullity(A) = 2'],
  ARRAY['rank-nullity', 'nullspace', 'linear-algebra'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='rank-nullity-theorem'), '', '2', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────
-- CONCEPT PROBLEMS: LINEAR ALGEBRA
-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-eigenvalue-meaning',
  'Interpret Eigenvalues',
  E'**Question:** What do eigenvalues represent when $A\\mathbf{v} = \\lambda\\mathbf{v}$?',
  'multiple_choice', 'Medium', 'Linear Algebra', 140,
  ARRAY['v is eigenvector, λ is scaling factor', 'Av scales v by λ without changing direction'],
  ARRAY['eigenvalues', 'eigenvectors', 'concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-eigenvalue-meaning'), 'A', 'Scaling factors: multiplying the eigenvector by λ leaves the direction unchanged', true, 0),
((SELECT id FROM problems WHERE slug='concept-eigenvalue-meaning'), 'B', 'The determinant of the matrix', false, 1),
((SELECT id FROM problems WHERE slug='concept-eigenvalue-meaning'), 'C', 'The trace of the matrix', false, 2),
((SELECT id FROM problems WHERE slug='concept-eigenvalue-meaning'), 'D', 'The rank of the matrix', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'concept-matrix-invertible',
  'When is a Matrix Invertible?',
  E'**Question:** A square matrix $A$ is invertible if and only if:',
  'multiple_choice', 'Easy', 'Linear Algebra', 130,
  ARRAY['det(A) ≠ 0 means invertible', 'det(A) = 0 means singular (not invertible)'],
  ARRAY['matrices', 'invertible', 'determinant', 'concept'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='concept-matrix-invertible'), 'A', 'det(A) ≠ 0', true, 0),
((SELECT id FROM problems WHERE slug='concept-matrix-invertible'), 'B', 'det(A) = 0', false, 1),
((SELECT id FROM problems WHERE slug='concept-matrix-invertible'), 'C', 'All diagonal entries are non-zero', false, 2),
((SELECT id FROM problems WHERE slug='concept-matrix-invertible'), 'D', 'The matrix is square', false, 3)
ON CONFLICT DO NOTHING;
