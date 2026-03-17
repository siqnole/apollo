-- ── Backpropagation Problems ─────────────────────────────────────────────
-- Run: psql -U postgres -d apollo -h localhost -f backprop_problems.sql

-- ── OPTION 1: Gradient of a Prefix Sum ───────────────────────────────────
-- Each output depends on all previous inputs, so gradients accumulate.

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'prefix-sum-gradient',
  'Backprop Through a Prefix Sum',
  E'The **prefix sum** (cumulative sum) maps an input vector $\\mathbf{x}$ to output $\\mathbf{s}$:\n\n$$s_i = \\sum_{j=1}^{i} x_j$$\n\nSo for $\\mathbf{x} = [x_1, x_2, x_3]$:\n$$s_1 = x_1, \\quad s_2 = x_1 + x_2, \\quad s_3 = x_1 + x_2 + x_3$$\n\nGiven a scalar loss $\\mathcal{L} = \\sum_i s_i$, backpropagate to find $\\partial \\mathcal{L} / \\partial x_i$.\n\n**Key insight:** $x_i$ appears in every output $s_j$ where $j \\geq i$, so:\n\n$$\\frac{\\partial \\mathcal{L}}{\\partial x_i} = \\sum_{j=i}^{n} \\frac{\\partial \\mathcal{L}}{\\partial s_j} \\cdot \\frac{\\partial s_j}{\\partial x_i} = \\sum_{j=i}^{n} 1 = n - i + 1$$\n\nImplement a function that:\n1. Computes the forward pass (prefix sums)\n2. Computes the backward pass (gradient of $\\mathcal{L} = \\sum_i s_i$ w.r.t. each $x_i$)\n3. Returns both the prefix sums and the gradients\n\n**Input:** Space-separated numbers.\n**Output:** Two lines — prefix sums space-separated, then gradients space-separated.\n\n**Example:**\n```\nInput:  1 2 3\nOutput:\n2.0 5.0 9.0   ← wait, that uses x values\n3 2 1         ← gradients: x1 appears in s1,s2,s3 → grad=3\n```\n\n**Actual example:**\n```\nInput:  1 2 3\nForward:  1 3 6\nGradients: 3 2 1\n```',
  'code', 'Medium', 'Machine Learning', 160,
  '{"javascript":"function prefixSumBackprop(x) {\n  const n = x.length;\n\n  // Forward pass: compute prefix sums\n  const s = new Array(n).fill(0);\n  for (let i = 0; i < n; i++) {\n    s[i] = (i === 0 ? 0 : s[i-1]) + x[i];\n  }\n\n  // Backward pass: dL/dx_i = number of outputs that include x_i\n  // Loss = sum(s), so dL/ds_i = 1 for all i\n  // x_i contributes to s_i, s_{i+1}, ..., s_{n-1}\n  const grad = new Array(n).fill(0);\n  // your code here\n\n  return { forward: s, gradients: grad };\n}","python":"def prefix_sum_backprop(x):\n    n = len(x)\n\n    # Forward pass\n    s = [0] * n\n    for i in range(n):\n        s[i] = (s[i-1] if i > 0 else 0) + x[i]\n\n    # Backward pass: dL/dx_i = n - i\n    grad = [0] * n\n    # your code here\n\n    return s, grad","cpp":"#include <vector>\nusing namespace std;\npair<vector<double>, vector<double>> prefixSumBackprop(vector<double> x) {\n    int n = x.size();\n\n    // Forward pass\n    vector<double> s(n);\n    s[0] = x[0];\n    for (int i = 1; i < n; i++) s[i] = s[i-1] + x[i];\n\n    // Backward pass\n    vector<double> grad(n, 0);\n    // your code here\n\n    return {s, grad};\n}"}',
  ARRAY[
    'In the forward pass, s[i] = s[i-1] + x[i]',
    'The loss is L = sum(s), so dL/ds[i] = 1 for every i',
    'x[i] contributes to s[i], s[i+1], ..., s[n-1] — that is (n-i) outputs',
    'So dL/dx[i] = n - i (using 0-based indexing)',
    'For x = [1,2,3]: grad = [3, 2, 1] — x[0] appears in all 3 sums'
  ],
  ARRAY['backpropagation', 'prefix-sum', 'gradients', 'chain-rule', 'machine-learning', 'autograd'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='prefix-sum-gradient'), '1 2 3', E'1.0 3.0 6.0\n3 2 1', false, 0),
((SELECT id FROM problems WHERE slug='prefix-sum-gradient'), '4 3 2 1', E'4.0 7.0 9.0 10.0\n4 3 2 1', false, 1),
((SELECT id FROM problems WHERE slug='prefix-sum-gradient'), '5', E'5.0\n1', true, 2),
((SELECT id FROM problems WHERE slug='prefix-sum-gradient'), '1 1 1 1 1', E'1.0 2.0 3.0 4.0 5.0\n5 4 3 2 1', true, 3)
ON CONFLICT DO NOTHING;

-- ── OPTION 2: Backpropagation Through Time (BPTT) — Simple RNN ────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'bptt-simple-rnn',
  'Backpropagation Through Time (BPTT)',
  E'A simple RNN cell processes a sequence one step at a time, carrying a hidden state forward:\n\n$$h_t = \\tanh(W_h \\cdot h_{t-1} + W_x \\cdot x_t)$$\n\nwhere:\n- $h_t$ is the hidden state at time $t$\n- $x_t$ is the input at time $t$\n- $W_h$, $W_x$ are scalar weights (simplified to scalars here)\n- $h_0 = 0$\n\n**Loss:** $\\mathcal{L} = \\frac{1}{2}(h_T - y)^2$ where $y$ is the target.\n\n**Your task:** Implement the full forward pass and BPTT to compute:\n- $\\partial \\mathcal{L} / \\partial W_h$\n- $\\partial \\mathcal{L} / \\partial W_x$\n\n**BPTT chain rule** (unrolling backwards from $t=T$ to $t=1$):\n\n$$\\delta_t = \\frac{\\partial \\mathcal{L}}{\\partial h_t} \\cdot (1 - h_t^2) \\quad \\text{(tanh derivative)}$$\n\n$$\\frac{\\partial \\mathcal{L}}{\\partial W_h} = \\sum_{t=1}^{T} \\delta_t \\cdot h_{t-1}$$\n\n$$\\frac{\\partial \\mathcal{L}}{\\partial W_x} = \\sum_{t=1}^{T} \\delta_t \\cdot x_t$$\n\n$$\\frac{\\partial \\mathcal{L}}{\\partial h_{t-1}} = \\delta_t \\cdot W_h$$\n\n**Input format:**\n- Line 1: `W_h W_x` (weights)\n- Line 2: `x_1 x_2 ... x_T` (input sequence)\n- Line 3: `y` (target)\n\n**Output:** `dW_h dW_x` rounded to 4 decimal places.',
  'code', 'Hard', 'Machine Learning', 250,
  '{"javascript":"function bptt(Wh, Wx, xs, y) {\n  const T = xs.length;\n  const h = new Array(T + 1).fill(0); // h[0] = 0\n\n  // Forward pass\n  for (let t = 1; t <= T; t++) {\n    h[t] = Math.tanh(Wh * h[t-1] + Wx * xs[t-1]);\n  }\n\n  // Backward pass\n  let dWh = 0, dWx = 0;\n  // dL/dh_T = (h_T - y)\n  let dh = h[T] - y;\n\n  for (let t = T; t >= 1; t--) {\n    // delta_t = dh * (1 - h[t]^2)  [tanh derivative]\n    const delta = dh * (1 - h[t] * h[t]);\n    dWh += delta * h[t-1];\n    dWx += delta * xs[t-1];\n    // propagate gradient back to h[t-1]\n    dh = delta * Wh;\n  }\n\n  return { dWh, dWx };\n}","python":"import math\ndef bptt(Wh, Wx, xs, y):\n    T = len(xs)\n    h = [0.0] * (T + 1)  # h[0] = 0\n\n    # Forward pass\n    for t in range(1, T + 1):\n        h[t] = math.tanh(Wh * h[t-1] + Wx * xs[t-1])\n\n    # Backward pass\n    dWh, dWx = 0.0, 0.0\n    dh = h[T] - y  # dL/dh_T\n\n    for t in range(T, 0, -1):\n        delta = dh * (1 - h[t] ** 2)  # tanh derivative\n        dWh += delta * h[t-1]\n        dWx += delta * xs[t-1]\n        dh = delta * Wh  # propagate to h[t-1]\n\n    return dWh, dWx","cpp":"#include <vector>\n#include <cmath>\nusing namespace std;\npair<double,double> bptt(double Wh, double Wx, vector<double> xs, double y) {\n    int T = xs.size();\n    vector<double> h(T+1, 0.0);\n\n    // Forward pass\n    for (int t = 1; t <= T; t++)\n        h[t] = tanh(Wh * h[t-1] + Wx * xs[t-1]);\n\n    // Backward pass\n    double dWh = 0, dWx = 0;\n    double dh = h[T] - y;\n\n    for (int t = T; t >= 1; t--) {\n        double delta = dh * (1 - h[t]*h[t]);\n        dWh += delta * h[t-1];\n        dWx += delta * xs[t-1];\n        dh = delta * Wh;\n    }\n\n    return {dWh, dWx};\n}"}',
  ARRAY[
    'Forward: h[t] = tanh(Wh * h[t-1] + Wx * x[t])',
    'Start backprop with dh = h[T] - y  (derivative of MSE loss)',
    'At each step t going backwards: delta = dh * (1 - h[t]^2)',
    'Accumulate: dWh += delta * h[t-1],  dWx += delta * x[t]',
    'Then pass gradient back: dh = delta * Wh',
    'The (1 - h^2) term is the derivative of tanh'
  ],
  ARRAY['bptt', 'rnn', 'backpropagation', 'recurrent', 'sequence', 'machine-learning', 'deep-learning'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='bptt-simple-rnn'), E'0.5 0.5\n1.0 2.0 3.0\n1.0', '-0.0419 -0.1311', false, 0),
((SELECT id FROM problems WHERE slug='bptt-simple-rnn'), E'0.0 1.0\n1.0\n0.0', '0.0 0.5990', false, 1),
((SELECT id FROM problems WHERE slug='bptt-simple-rnn'), E'0.8 0.3\n0.5 1.0 0.5 1.0\n0.5', '-0.0952 -0.0705', true, 2)
ON CONFLICT DO NOTHING;

-- ── OPTION 3: Mini Autograd — Cumulative Sum with Gradient Tracking ────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'mini-autograd-cumsum',
  'Mini Autograd: Cumulative Sum',
  E'Build a **miniature autograd engine** that tracks a computation graph and computes gradients automatically via backpropagation.\n\nYour engine needs a `Value` class (or equivalent) where each node stores:\n- Its scalar value\n- Its gradient (`grad`, initialised to 0)\n- A `backward` function that propagates gradients to its inputs\n\nImplement these operations:\n- `add(a, b)` — addition node: $c = a + b$, backwards: $\\partial c / \\partial a = 1$, $\\partial c / \\partial b = 1$\n- `cumsum(values)` — build a graph of additions that produces prefix sums\n\nThen call `backward()` from the **final output node** (last prefix sum), which should propagate gradients all the way back to the inputs.\n\nWith loss node = last prefix sum $s_n = x_1 + x_2 + \\cdots + x_n$ and $dL/ds_n = 1$:\n\n$$\\frac{\\partial s_n}{\\partial x_i} = 1 \\quad \\forall i$$\n\nBut if you call backward on $s_n$ **and** accumulate through the addition chain, each $x_i$ that contributed to any intermediate sum also picks up gradients from **those** sums too — since each intermediate node $s_i$ feeds into $s_{i+1}$.\n\nThe total gradient of $x_i$ with respect to $s_n$ propagated through the full chain = $n - i + 1$ (1-indexed).\n\n**Your task:**\n1. Implement the `Value` class with `add` and a `backward()` method\n2. Build the cumulative sum graph\n3. Call backward on the **sum of all prefix sums** (loss = $\\sum_i s_i$)\n4. Return the gradient of each input\n\n**Input:** Space-separated numbers.\n**Output:** Gradients of each input, space-separated as integers.',
  'code', 'Expert', 'Machine Learning', 320,
  $code${"javascript":"class Value {\n  constructor(data, children = [], op = '') {\n    this.data = data;\n    this.grad = 0;\n    this._backward = () => {};\n    this._prev = children;\n    this._op = op;\n  }\n\n  add(other) {\n    const out = new Value(this.data + other.data, [this, other], '+');\n    out._backward = () => {\n      // gradient flows equally to both inputs\n      this.grad += out.grad;\n      other.grad += out.grad;\n    };\n    return out;\n  }\n\n  backward() {\n    // Topological sort then reverse\n    const topo = [];\n    const visited = new Set();\n    const build = (v) => {\n      if (!visited.has(v)) {\n        visited.add(v);\n        for (const child of v._prev) build(child);\n        topo.push(v);\n      }\n    };\n    build(this);\n    this.grad = 1;\n    for (const v of topo.reverse()) v._backward();\n  }\n}\n\nfunction miniAutogradCumsum(xs) {\n  // Wrap inputs as Value nodes\n  const inputs = xs.map(x => new Value(x));\n\n  // Build prefix sums as a graph\n  const prefixSums = [];\n  // your code here — build s[0] = inputs[0], s[1] = s[0].add(inputs[1]), etc.\n\n  // Build total loss = sum of all prefix sums\n  // your code here\n\n  // Call backward\n  // loss.backward();\n\n  // Return gradients\n  return inputs.map(v => v.grad);\n}","python":"class Value:\n    def __init__(self, data, children=(), op=''):\n        self.data = data\n        self.grad = 0\n        self._backward = lambda: None\n        self._prev = set(children)\n        self._op = op\n\n    def __add__(self, other):\n        out = Value(self.data + other.data, (self, other), '+')\n        def _backward():\n            self.grad += out.grad\n            other.grad += out.grad\n        out._backward = _backward\n        return out\n\n    def backward(self):\n        topo = []\n        visited = set()\n        def build(v):\n            if v not in visited:\n                visited.add(v)\n                for child in v._prev:\n                    build(child)\n                topo.append(v)\n        build(self)\n        self.grad = 1\n        for v in reversed(topo):\n            v._backward()\n\ndef mini_autograd_cumsum(xs):\n    inputs = [Value(x) for x in xs]\n\n    # Build prefix sum graph\n    prefix_sums = []\n    # s[0] = inputs[0]\n    # s[i] = s[i-1] + inputs[i]\n    # your code here\n\n    # Build loss = sum of all prefix sums\n    # your code here\n\n    # loss.backward()\n\n    return [v.grad for v in inputs]"}$code$,
  ARRAY[
    'Wrap each input as a Value node',
    'Build prefix sums: s[0]=inputs[0], s[i]=s[i-1]+inputs[i]',
    'Build total loss by adding all prefix sums together: loss = s[0]+s[1]+...+s[n-1]',
    'Set loss.grad = 1 then call backward() (or call loss.backward())',
    'The backward pass will propagate gradients through the graph automatically',
    'Expected: grad[i] = n - i (0-indexed) because x[i] contributes to s[i], s[i+1],...,s[n-1]'
  ],
  ARRAY['autograd', 'backpropagation', 'computation-graph', 'prefix-sum', 'machine-learning', 'deep-learning', 'expert'],
  ARRAY['javascript','python']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='mini-autograd-cumsum'), '1 2 3', '3 2 1', false, 0),
((SELECT id FROM problems WHERE slug='mini-autograd-cumsum'), '5 4 3 2 1', '5 4 3 2 1', false, 1),
((SELECT id FROM problems WHERE slug='mini-autograd-cumsum'), '7', '1', true, 2),
((SELECT id FROM problems WHERE slug='mini-autograd-cumsum'), '1 1 1 1', '4 3 2 1', true, 3)
ON CONFLICT DO NOTHING;

-- ── Update supported_languages ─────────────────────────────────────────────
UPDATE problems SET supported_languages = ARRAY['javascript','python','cpp']
WHERE slug IN ('prefix-sum-gradient', 'bptt-simple-rnn');

UPDATE problems SET supported_languages = ARRAY['javascript','python']
WHERE slug = 'mini-autograd-cumsum';