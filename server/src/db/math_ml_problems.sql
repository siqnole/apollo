-- ── Math, ML & Data Science Problems ───────────────────────────────────────
-- Run: psql -U postgres -d apollo -h localhost -f math_ml_problems.sql
-- Requires LaTeX rendering (KaTeX) in the frontend.

-- ── MULTIPLE CHOICE / THEORY ─────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sigmoid-derivative',
  'Derive the Sigmoid Derivative',
  E'The sigmoid function is defined as:\n\n$$\\sigma(x) = \\frac{1}{1 + e^{-x}}$$\n\nWhich of the following correctly expresses its derivative $\\sigma''(x)$?\n\nThis derivative is fundamental to backpropagation in neural networks.',
  'multiple_choice', 'Medium', 'Machine Learning', 120,
  ARRAY['Try rewriting sigma as (1 + e^{-x})^{-1} and applying the chain rule', 'sigma(x) * (1 - sigma(x)) is a famous identity — can you derive it?'],
  ARRAY['calculus', 'sigmoid', 'backpropagation', 'neural-networks', 'derivatives'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='sigmoid-derivative'), 'A', 'σ(x)(1 - σ(x))', true, 0),
((SELECT id FROM problems WHERE slug='sigmoid-derivative'), 'B', 'σ(x)²', false, 1),
((SELECT id FROM problems WHERE slug='sigmoid-derivative'), 'C', '1 - σ(x)', false, 2),
((SELECT id FROM problems WHERE slug='sigmoid-derivative'), 'D', 'e^{-x} / (1 + e^{-x})', false, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'cross-entropy-loss',
  'Cross-Entropy Loss',
  E'Binary cross-entropy loss is defined as:\n\n$$\mathcal{L}(y, \hat{y}) = -\\left[ y \\log(\\hat{y}) + (1 - y) \\log(1 - \\hat{y}) \\right]$$\n\nwhere $y \\in \\{0, 1\\}$ is the true label and $\\hat{y} \\in (0, 1)$ is the predicted probability.\n\n**Question:** If the true label is $y = 1$ and the model predicts $\\hat{y} = 0.9$, what is the loss?\n\nRound to 4 decimal places.',
  'fill_blank', 'Medium', 'Machine Learning', 130,
  ARRAY['When y=1, the (1-y) term vanishes', 'L = -log(0.9)', 'ln(0.9) ≈ -0.10536'],
  ARRAY['loss-functions', 'cross-entropy', 'classification', 'machine-learning'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='cross-entropy-loss'), '', '0.1054', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'softmax-function',
  'Softmax Normalisation',
  E'The softmax function converts a vector of real numbers into a probability distribution:\n\n$$\\text{softmax}(z_i) = \\frac{e^{z_i}}{\\sum_{j=1}^{K} e^{z_j}}$$\n\nGiven the logit vector $\\mathbf{z} = [2.0,\\ 1.0,\\ 0.1]$, compute $\\text{softmax}(\\mathbf{z})$.\n\n**Output:** Three space-separated probabilities rounded to 4 decimal places.\n\n**Example format:** `0.6590 0.2424 0.0986`',
  'fill_blank', 'Medium', 'Machine Learning', 130,
  ARRAY['Compute e^2, e^1, e^0.1 first', 'Divide each by the sum', 'e^2 ≈ 7.389, e^1 ≈ 2.718, e^0.1 ≈ 1.105'],
  ARRAY['softmax', 'probability', 'classification', 'machine-learning'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='softmax-function'), '', '0.6590 0.2424 0.0986', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'gradient-descent-step',
  'Gradient Descent Update',
  E'The gradient descent parameter update rule is:\n\n$$\\theta_{t+1} = \\theta_t - \\eta \\nabla_\\theta \\mathcal{L}(\\theta_t)$$\n\nwhere $\\eta$ is the learning rate and $\\nabla_\\theta \\mathcal{L}$ is the gradient of the loss.\n\n**Given:**\n- Current parameter: $\\theta = 3.5$\n- Learning rate: $\\eta = 0.1$\n- Gradient: $\\nabla_\\theta \\mathcal{L} = -2.4$\n\n**Question:** What is $\\theta$ after one update step?',
  'fill_blank', 'Easy', 'Machine Learning', 80,
  ARRAY['theta_new = theta - learning_rate * gradient', 'Watch the sign: gradient is negative here'],
  ARRAY['gradient-descent', 'optimization', 'machine-learning', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='gradient-descent-step'), '', '3.74', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'bayes-theorem',
  'Bayes'' Theorem Application',
  E'Bayes'' theorem relates conditional probabilities:\n\n$$P(A \\mid B) = \\frac{P(B \\mid A) \\cdot P(A)}{P(B)}$$\n\n**Medical test scenario:**\n- Disease prevalence: $P(D) = 0.01$ (1% of population)\n- Test sensitivity: $P(+ \\mid D) = 0.95$\n- Test specificity: $P(- \\mid \\neg D) = 0.90$, so $P(+ \\mid \\neg D) = 0.10$\n\nA patient tests positive. What is the probability they actually have the disease, $P(D \\mid +)$?\n\nRound to 4 decimal places.',
  'fill_blank', 'Hard', 'Data Science', 180,
  ARRAY['P(+) = P(+|D)P(D) + P(+|¬D)P(¬D)', 'P(D) = 0.01, P(¬D) = 0.99', 'P(+) = 0.95×0.01 + 0.10×0.99 = 0.1085', 'P(D|+) = 0.0095 / 0.1085'],
  ARRAY['bayes', 'probability', 'statistics', 'data-science'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='bayes-theorem'), '', '0.0876', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'cosine-similarity',
  'Cosine Similarity',
  E'Cosine similarity measures the angle between two vectors:\n\n$$\\cos(\\theta) = \\frac{\\mathbf{a} \\cdot \\mathbf{b}}{\\|\\mathbf{a}\\| \\|\\mathbf{b}\\|}$$\n\nwhere $\\mathbf{a} \\cdot \\mathbf{b} = \\sum_i a_i b_i$ is the dot product and $\\|\\mathbf{a}\\| = \\sqrt{\\sum_i a_i^2}$.\n\n**Given:**\n$$\\mathbf{a} = [1, 2, 3], \\quad \\mathbf{b} = [4, 5, 6]$$\n\nCompute $\\cos(\\theta)$. Round to 4 decimal places.',
  'fill_blank', 'Easy', 'Data Science', 90,
  ARRAY['Dot product: 1×4 + 2×5 + 3×6 = 32', '‖a‖ = sqrt(1+4+9) = sqrt(14)', '‖b‖ = sqrt(16+25+36) = sqrt(77)'],
  ARRAY['linear-algebra', 'cosine-similarity', 'vectors', 'embeddings', 'data-science'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='cosine-similarity'), '', '0.9746', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'pca-variance',
  'PCA: Explained Variance',
  E'Principal Component Analysis (PCA) finds directions of maximum variance. The explained variance ratio of principal component $i$ is:\n\n$$\\text{EVR}_i = \\frac{\\lambda_i}{\\sum_{j=1}^{n} \\lambda_j}$$\n\nwhere $\\lambda_i$ are the eigenvalues of the covariance matrix.\n\n**Given eigenvalues:** $\\lambda = [4.5,\\ 2.1,\\ 0.9,\\ 0.3,\\ 0.2]$\n\n**Questions:**\n1. What is the explained variance ratio of PC1? (round to 4 dp)\n2. How many components are needed to explain at least 90% of variance?\n\n**Output format:** Two space-separated values, e.g. `0.5625 3`',
  'fill_blank', 'Medium', 'Data Science', 140,
  ARRAY['Sum all eigenvalues first: 4.5+2.1+0.9+0.3+0.2 = 8.0', 'EVR_1 = 4.5/8.0 = 0.5625', 'Cumulative: PC1=56.25%, PC1+PC2=81.75%, PC1+PC2+PC3=93.0%'],
  ARRAY['pca', 'dimensionality-reduction', 'eigenvalues', 'linear-algebra', 'data-science'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='pca-variance'), '', '0.5625 3', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'relu-derivative',
  'ReLU and Leaky ReLU Derivatives',
  E'The **ReLU** (Rectified Linear Unit) activation function is:\n\n$$\\text{ReLU}(x) = \\max(0, x)$$\n\nIts derivative is:\n\n$$\\text{ReLU}''(x) = \\begin{cases} 1 & x > 0 \\\\ 0 & x \\leq 0 \\end{cases}$$\n\n**Leaky ReLU** with slope $\\alpha = 0.01$:\n\n$$\\text{LeakyReLU}(x) = \\begin{cases} x & x > 0 \\\\ 0.01x & x \\leq 0 \\end{cases}$$\n\n**Question:** Which property of ReLU causes the **dying ReLU problem**, and how does Leaky ReLU fix it?\n\nWrite 2-4 sentences.',
  'short_answer', 'Medium', 'Machine Learning', 110,
  ARRAY['Think about what happens to the gradient when x < 0', 'A dead neuron can never recover — why?', 'Leaky ReLU has a non-zero gradient for negative inputs'],
  ARRAY['relu', 'activation-functions', 'backpropagation', 'neural-networks', 'machine-learning'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'mean-squared-error',
  'Implement Mean Squared Error',
  E'Mean Squared Error (MSE) measures the average squared difference between predictions and targets:\n\n$$\\text{MSE} = \\frac{1}{n} \\sum_{i=1}^{n} (y_i - \\hat{y}_i)^2$$\n\nImplement a function that takes two arrays of equal length — `actual` and `predicted` — and returns the MSE.\n\n**Example:**\n```\nactual    = [2, 4, 6, 8]\npredicted = [2.5, 3.5, 5.5, 8.5]\nMSE = ((0.25 + 0.25 + 0.25 + 0.25) / 4) = 0.25\n```\n\n**Input:** Two lines — actual values space-separated, then predicted values space-separated.\n**Output:** MSE rounded to 4 decimal places.',
  'code', 'Easy', 'Machine Learning', 90,
  '{"javascript":"function mse(actual, predicted) {\n  // your code here\n  return 0;\n}","python":"def mse(actual, predicted):\n    # your code here\n    pass","cpp":"#include <vector>\n#include <cmath>\nusing namespace std;\ndouble mse(vector<double> actual, vector<double> predicted) {\n    // your code here\n    return 0.0;\n}"}',
  ARRAY['Sum (actual[i] - predicted[i])^2 for all i', 'Divide by n (length of the array)', 'MSE is always non-negative'],
  ARRAY['loss-functions', 'mse', 'regression', 'machine-learning'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='mean-squared-error'), E'2 4 6 8\n2.5 3.5 5.5 8.5', '0.25', false, 0),
((SELECT id FROM problems WHERE slug='mean-squared-error'), E'1 2 3\n1 2 3', '0.0', false, 1),
((SELECT id FROM problems WHERE slug='mean-squared-error'), E'0 0 0\n1 1 1', '1.0', true, 2),
((SELECT id FROM problems WHERE slug='mean-squared-error'), E'10\n7', '9.0', true, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'z-score-normalisation',
  'Z-Score Normalisation',
  E'Z-score normalisation (standardisation) transforms data to have mean 0 and standard deviation 1:\n\n$$z_i = \\frac{x_i - \\mu}{\\sigma}$$\n\nwhere:\n$$\\mu = \\frac{1}{n}\\sum_{i=1}^n x_i, \\quad \\sigma = \\sqrt{\\frac{1}{n}\\sum_{i=1}^n (x_i - \\mu)^2}$$\n\nImplement a function that takes an array and returns the z-score normalised version.\n\n**Input:** Space-separated numbers.\n**Output:** Space-separated z-scores, each rounded to 4 decimal places.',
  'code', 'Easy', 'Data Science', 100,
  '{"javascript":"function zScore(arr) {\n  // your code here\n  return arr;\n}","python":"def z_score(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\n#include <cmath>\nusing namespace std;\nvector<double> zScore(vector<double> arr) {\n    // your code here\n    return arr;\n}"}',
  ARRAY['Compute mean first: sum / n', 'Compute std: sqrt(sum of (x-mean)^2 / n)', 'Then z[i] = (x[i] - mean) / std'],
  ARRAY['normalisation', 'statistics', 'preprocessing', 'data-science'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='z-score-normalisation'), '2 4 4 4 5 5 7 9', '-1.5 -0.5 -0.5 -0.5 0.0 0.0 1.0 2.0', false, 0),
((SELECT id FROM problems WHERE slug='z-score-normalisation'), '1 2 3', '-1.2247 0.0 1.2247', false, 1),
((SELECT id FROM problems WHERE slug='z-score-normalisation'), '5 5 5', '0.0 0.0 0.0', true, 2)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'dot-product-matrix',
  'Matrix Dot Product',
  E'Matrix multiplication (dot product) is a fundamental operation in ML. For matrices $A$ (m×n) and $B$ (n×p):\n\n$$(AB)_{ij} = \\sum_{k=1}^{n} A_{ik} B_{kj}$$\n\nImplement matrix multiplication from scratch — **no library functions** (no numpy.dot, no matmul).\n\n**Input format:**\n- Line 1: `m n` (rows and cols of A)\n- Lines 2 to m+1: rows of A\n- Line m+2: `n p` (rows and cols of B)\n- Lines m+3 onwards: rows of B\n\n**Output:** The result matrix, one row per line, space-separated, rounded to 2 decimal places.\n\n**Example:**\n```\n2 3\n1 2 3\n4 5 6\n3 2\n7 8\n9 10\n11 12\n```\nOutput:\n```\n58.00 64.00\n139.00 154.00\n```',
  'code', 'Medium', 'Data Science', 150,
  '{"javascript":"function matmul(A, B) {\n  // A is m×n, B is n×p\n  // return m×p result\n  const m = A.length, n = A[0].length, p = B[0].length;\n  const C = Array.from({length: m}, () => new Array(p).fill(0));\n  // your code here\n  return C;\n}","python":"def matmul(A, B):\n    m, n, p = len(A), len(A[0]), len(B[0])\n    C = [[0.0]*p for _ in range(m)]\n    # your code here\n    return C","cpp":"#include <vector>\nusing namespace std;\nvector<vector<double>> matmul(vector<vector<double>>& A, vector<vector<double>>& B) {\n    int m = A.size(), n = A[0].size(), p = B[0].size();\n    vector<vector<double>> C(m, vector<double>(p, 0));\n    // your code here\n    return C;\n}"}',
  ARRAY['Three nested loops: i (rows of A), j (cols of B), k (shared dimension)', 'C[i][j] += A[i][k] * B[k][j]', 'Check dimensions: A must be m×n, B must be n×p'],
  ARRAY['linear-algebra', 'matrix-multiplication', 'numpy', 'data-science'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='dot-product-matrix'), E'2 3\n1 2 3\n4 5 6\n3 2\n7 8\n9 10\n11 12', E'58.00 64.00\n139.00 154.00', false, 0),
((SELECT id FROM problems WHERE slug='dot-product-matrix'), E'1 2\n1 2\n2 1\n3\n4', '11.00', false, 1),
((SELECT id FROM problems WHERE slug='dot-product-matrix'), E'2 2\n1 0\n0 1\n2 2\n5 6\n7 8', E'5.00 6.00\n7.00 8.00', true, 2)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'implement-softmax',
  'Implement Softmax',
  E'Implement the softmax function:\n\n$$\\text{softmax}(z_i) = \\frac{e^{z_i - \\max(\\mathbf{z})}}{\\sum_{j} e^{z_j - \\max(\\mathbf{z})}}$$\n\n> **Note:** We subtract $\\max(\\mathbf{z})$ before exponentiating for **numerical stability** — this prevents overflow when values are large, since $e^{800}$ is infinity in floating point.\n\n**Input:** Space-separated floats.\n**Output:** Space-separated probabilities rounded to 4 decimal places.',
  'code', 'Medium', 'Machine Learning', 130,
  '{"javascript":"function softmax(z) {\n  // subtract max for numerical stability\n  const maxZ = Math.max(...z);\n  // your code here\n  return z;\n}","python":"import math\ndef softmax(z):\n    max_z = max(z)\n    # your code here\n    return z","cpp":"#include <vector>\n#include <cmath>\n#include <algorithm>\nusing namespace std;\nvector<double> softmax(vector<double> z) {\n    double maxZ = *max_element(z.begin(), z.end());\n    // your code here\n    return z;\n}"}',
  ARRAY['Subtract max(z) from all elements first', 'Compute e^(z_i - max_z) for each element', 'Divide each by the sum of all exponentials'],
  ARRAY['softmax', 'activation-functions', 'numerical-stability', 'machine-learning'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='implement-softmax'), '2.0 1.0 0.1', '0.6590 0.2424 0.0986', false, 0),
((SELECT id FROM problems WHERE slug='implement-softmax'), '1.0 1.0 1.0', '0.3333 0.3333 0.3333', false, 1),
((SELECT id FROM problems WHERE slug='implement-softmax'), '0.0', '1.0', true, 2),
((SELECT id FROM problems WHERE slug='implement-softmax'), '1000.0 1000.0', '0.5 0.5', true, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'gaussian-blur-kernel',
  'Gaussian Blur Kernel',
  E'A 2D Gaussian kernel used for image blurring is:\n\n$$G(x, y) = \\frac{1}{2\\pi\\sigma^2} e^{-\\frac{x^2 + y^2}{2\\sigma^2}}$$\n\nTo create a discrete $n \\times n$ kernel, evaluate $G(x, y)$ at integer positions centered at 0, then **normalise** so all values sum to 1.\n\nImplement a function that generates a Gaussian blur kernel.\n\n**Input:** Two values — kernel size $n$ (odd integer) and $\\sigma$.\n**Output:** The $n \\times n$ kernel, one row per line, values rounded to 4 decimal places.\n\n**Example** ($n=3$, $\\sigma=1.0$):\n```\n0.0751 0.1238 0.0751\n0.1238 0.2042 0.1238\n0.0751 0.1238 0.0751\n```',
  'code', 'Hard', 'Data Science', 200,
  '{"javascript":"function gaussianKernel(n, sigma) {\n  const half = Math.floor(n / 2);\n  const kernel = [];\n  let sum = 0;\n  for (let y = -half; y <= half; y++) {\n    const row = [];\n    for (let x = -half; x <= half; x++) {\n      const val = Math.exp(-(x*x + y*y) / (2 * sigma * sigma));\n      row.push(val);\n      sum += val;\n    }\n    kernel.push(row);\n  }\n  // normalise\n  // your code here\n  return kernel;\n}","python":"import math\ndef gaussian_kernel(n, sigma):\n    half = n // 2\n    kernel = []\n    total = 0\n    for y in range(-half, half + 1):\n        row = []\n        for x in range(-half, half + 1):\n            val = math.exp(-(x**2 + y**2) / (2 * sigma**2))\n            row.append(val)\n            total += val\n        kernel.append(row)\n    # normalise — divide every element by total\n    # your code here\n    return kernel"}',
  ARRAY['The 1/(2*pi*sigma^2) prefactor cancels out during normalisation, so you can skip it', 'Compute exp(-(x^2+y^2)/(2*sigma^2)) for each (x,y)', 'Sum all values, then divide each by the sum'],
  ARRAY['gaussian-blur', 'image-processing', 'convolution', 'computer-vision', 'data-science'],
  ARRAY['javascript','python']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='gaussian-blur-kernel'), E'3\n1.0', E'0.0751 0.1238 0.0751\n0.1238 0.2042 0.1238\n0.0751 0.1238 0.0751', false, 0),
((SELECT id FROM problems WHERE slug='gaussian-blur-kernel'), E'1\n1.0', '1.0', true, 1)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'backpropagation-single-layer',
  'Backpropagation: Single Layer',
  E'Consider a single-layer neural network with one neuron:\n\n$$\\hat{y} = \\sigma(wx + b)$$\n\nwhere $\\sigma$ is sigmoid. The loss is MSE:\n\n$$\\mathcal{L} = \\frac{1}{2}(y - \\hat{y})^2$$\n\nBackpropagation computes gradients via the chain rule:\n\n$$\\frac{\\partial \\mathcal{L}}{\\partial w} = \\frac{\\partial \\mathcal{L}}{\\partial \\hat{y}} \\cdot \\frac{\\partial \\hat{y}}{\\partial z} \\cdot \\frac{\\partial z}{\\partial w}$$\n\nwhere $z = wx + b$.\n\n**Given:**\n- $x = 2.0$, $w = 0.5$, $b = 0.1$, $y = 1.0$\n- $\\sigma(x) = 1/(1+e^{-x})$, $\\sigma''(x) = \\sigma(x)(1-\\sigma(x))$\n\nCompute $\\partial\\mathcal{L}/\\partial w$. Round to 4 decimal places.',
  'fill_blank', 'Hard', 'Machine Learning', 200,
  ARRAY['z = w*x + b = 0.5*2 + 0.1 = 1.1', 'y_hat = sigma(1.1) ≈ 0.7503', 'dL/dy_hat = -(y - y_hat) = -(1 - 0.7503) = -0.2497', 'dy_hat/dz = sigma(z)(1-sigma(z)) ≈ 0.7503 * 0.2497 ≈ 0.1874', 'dz/dw = x = 2.0', 'Multiply all three together'],
  ARRAY['backpropagation', 'chain-rule', 'gradients', 'neural-networks', 'calculus'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='backpropagation-single-layer'), '', '-0.0936', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'kl-divergence',
  'KL Divergence',
  E'The Kullback-Leibler divergence measures how one probability distribution $P$ differs from another $Q$:\n\n$$D_{KL}(P \\| Q) = \\sum_{i} P(i) \\log \\frac{P(i)}{Q(i)}$$\n\nNote: $D_{KL}$ is **not symmetric** — $D_{KL}(P\\|Q) \\neq D_{KL}(Q\\|P)$ in general.\n\nImplement a function that computes KL divergence.\n\n**Input:** Two lines — P values space-separated, then Q values space-separated (both valid probability distributions summing to 1).\n**Output:** $D_{KL}(P \\| Q)$ rounded to 4 decimal places.',
  'code', 'Hard', 'Machine Learning', 190,
  '{"javascript":"function klDivergence(P, Q) {\n  // sum P[i] * log(P[i] / Q[i])\n  // use natural log (Math.log)\n  return 0;\n}","python":"import math\ndef kl_divergence(P, Q):\n    # sum P[i] * log(P[i] / Q[i])\n    pass","cpp":"#include <vector>\n#include <cmath>\nusing namespace std;\ndouble klDivergence(vector<double> P, vector<double> Q) {\n    // your code here\n    return 0.0;\n}"}',
  ARRAY['Use natural log (ln)', 'Skip terms where P[i] = 0 (0 * log(0) = 0 by convention)', 'KL divergence is always >= 0'],
  ARRAY['kl-divergence', 'information-theory', 'probability', 'machine-learning'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='kl-divergence'), E'0.4 0.6\n0.5 0.5', '0.0201', false, 0),
((SELECT id FROM problems WHERE slug='kl-divergence'), E'1.0\n1.0', '0.0', false, 1),
((SELECT id FROM problems WHERE slug='kl-divergence'), E'0.3 0.3 0.4\n0.2 0.4 0.4', '0.0238', true, 2)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'attention-mechanism',
  'Scaled Dot-Product Attention',
  E'The attention mechanism at the core of transformers:\n\n$$\\text{Attention}(Q, K, V) = \\text{softmax}\\left(\\frac{QK^T}{\\sqrt{d_k}}\\right) V$$\n\nwhere $Q$ (queries), $K$ (keys), $V$ (values) are matrices and $d_k$ is the key dimension.\n\n**Steps:**\n1. Compute scores: $S = QK^T / \\sqrt{d_k}$\n2. Apply softmax to each row of $S$\n3. Multiply by $V$\n\n**Given** ($d_k = 2$):\n$$Q = \\begin{bmatrix} 1 & 0 \\\\ 0 & 1 \\end{bmatrix}, \\quad K = \\begin{bmatrix} 1 & 0 \\\\ 0 & 1 \\end{bmatrix}, \\quad V = \\begin{bmatrix} 1 & 2 \\\\ 3 & 4 \\end{bmatrix}$$\n\nCompute the attention output. Output as a 2×2 matrix, one row per line, rounded to 4 decimal places.',
  'fill_blank', 'Expert', 'Machine Learning', 280,
  ARRAY['QK^T = Q @ K.T = identity @ identity = identity', 'Scale: divide by sqrt(2) ≈ 1.4142', 'Score matrix: [[0.7071, 0], [0, 0.7071]]', 'Apply softmax row-wise', 'softmax([0.7071, 0]) = [0.6742, 0.3258]', 'Multiply softmax weights by V rows'],
  ARRAY['attention', 'transformers', 'self-attention', 'deep-learning', 'machine-learning'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='attention-mechanism'), '', E'1.6517 2.6517\n1.6517 2.6517', false, 0)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'batch-normalisation',
  'Batch Normalisation',
  E'Batch normalisation normalises activations across a mini-batch to stabilise training:\n\n$$\\hat{x}_i = \\frac{x_i - \\mu_B}{\\sqrt{\\sigma_B^2 + \\epsilon}}$$\n\nwhere:\n- $\\mu_B = \\frac{1}{m}\\sum_{i=1}^m x_i$ is the batch mean\n- $\\sigma_B^2 = \\frac{1}{m}\\sum_{i=1}^m (x_i - \\mu_B)^2$ is the batch variance\n- $\\epsilon = 10^{-5}$ prevents division by zero\n\nThen scale and shift: $y_i = \\gamma \\hat{x}_i + \\beta$ (use $\\gamma = 1$, $\\beta = 0$ here).\n\nImplement batch normalisation.\n\n**Input:** Space-separated floats.\n**Output:** Normalised values, space-separated, rounded to 4 decimal places.',
  'code', 'Hard', 'Machine Learning', 200,
  '{"javascript":"function batchNorm(x, eps = 1e-5) {\n  // compute mean, variance, then normalise\n  return x;\n}","python":"def batch_norm(x, eps=1e-5):\n    # compute mean, variance, then normalise\n    return x","cpp":"#include <vector>\n#include <cmath>\nusing namespace std;\nvector<double> batchNorm(vector<double> x, double eps = 1e-5) {\n    // your code here\n    return x;\n}"}',
  ARRAY['Mean = sum(x) / n', 'Variance = sum((x_i - mean)^2) / n', 'x_hat_i = (x_i - mean) / sqrt(variance + eps)'],
  ARRAY['batch-normalisation', 'deep-learning', 'training', 'machine-learning'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='batch-normalisation'), '2 4 4 4 5 5 7 9', '-1.5 -0.5 -0.5 -0.5 0.0 0.0 1.0 2.0', false, 0),
((SELECT id FROM problems WHERE slug='batch-normalisation'), '1 2 3 4 5', '-1.4142 -0.7071 0.0 0.7071 1.4142', false, 1),
((SELECT id FROM problems WHERE slug='batch-normalisation'), '5 5 5 5', '0.0 0.0 0.0 0.0', true, 2)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'gradient-descent-implement',
  'Implement Gradient Descent',
  E'Implement **gradient descent** to minimise a quadratic loss function.\n\nYou are given the loss:\n\n$$\\mathcal{L}(\\theta) = (\\theta - 3)^2$$\n\nwhose gradient is:\n\n$$\\nabla \\mathcal{L}(\\theta) = 2(\\theta - 3)$$\n\nThe minimum is at $\\theta^* = 3$.\n\nStarting from $\\theta_0$, perform $n$ steps of gradient descent with learning rate $\\eta$:\n\n$$\\theta_{t+1} = \\theta_t - \\eta \\cdot 2(\\theta_t - 3)$$\n\n**Input:** Three space-separated values: `theta_0 eta n`\n**Output:** Final $\\theta$ rounded to 4 decimal places.',
  'code', 'Easy', 'Machine Learning', 100,
  '{"javascript":"function gradientDescent(theta, eta, n) {\n  for (let i = 0; i < n; i++) {\n    const grad = 2 * (theta - 3);\n    theta = theta - eta * grad;\n  }\n  return theta;\n}","python":"def gradient_descent(theta, eta, n):\n    for _ in range(n):\n        grad = 2 * (theta - 3)\n        theta = theta - eta * grad\n    return theta","cpp":"double gradientDescent(double theta, double eta, int n) {\n    for (int i = 0; i < n; i++) {\n        double grad = 2 * (theta - 3);\n        theta = theta - eta * grad;\n    }\n    return theta;\n}"}',
  ARRAY['gradient = 2*(theta - 3)', 'theta = theta - learning_rate * gradient', 'Repeat n times'],
  ARRAY['gradient-descent', 'optimization', 'machine-learning'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='gradient-descent-implement'), '0.0 0.1 100', '3.0', false, 0),
((SELECT id FROM problems WHERE slug='gradient-descent-implement'), '10.0 0.1 1', '8.6', false, 1),
((SELECT id FROM problems WHERE slug='gradient-descent-implement'), '3.0 0.1 10', '3.0', true, 2),
((SELECT id FROM problems WHERE slug='gradient-descent-implement'), '0.0 0.01 1000', '3.0', true, 3)
ON CONFLICT DO NOTHING;

-- ── Update supported_languages ─────────────────────────────────────────────
UPDATE problems SET supported_languages = ARRAY['any']
WHERE slug IN (
  'sigmoid-derivative', 'cross-entropy-loss', 'softmax-function',
  'gradient-descent-step', 'bayes-theorem', 'cosine-similarity',
  'pca-variance', 'relu-derivative', 'backpropagation-single-layer',
  'kl-divergence', 'attention-mechanism'
);

UPDATE problems SET supported_languages = ARRAY['javascript','python','cpp']
WHERE slug IN (
  'mean-squared-error', 'z-score-normalisation', 'dot-product-matrix',
  'implement-softmax', 'kl-divergence', 'batch-normalisation',
  'gradient-descent-implement'
);

UPDATE problems SET supported_languages = ARRAY['javascript','python']
WHERE slug = 'gaussian-blur-kernel';