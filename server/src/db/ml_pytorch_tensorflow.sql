-- ── PyTorch & TensorFlow Hands-On Problems ────────────────────────────────
-- Run: psql -U postgres -d apollo -h localhost -f ml_pytorch_tensorflow.sql
-- Requires Python with torch, tensorflow, matplotlib, numpy, pandas, scikit-learn

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'pytorch-tensor-basics',
  'PyTorch Tensor Creation and Operations',
  E'**Objective:** Learn PyTorch tensor fundamentals.\n\n**Task:**\n```python\nimport torch\n\n# Create a 2x3 tensor of random values\ntensor1 = torch.rand(2, 3)\n\n# Create a tensor with specific values\ntensor2 = torch.tensor([[1.0, 2.0, 3.0],\n                        [4.0, 5.0, 6.0]])\n\n# Element-wise multiplication\nresult = tensor1 * tensor2\n\n# Print the sum of all elements\nprint(result.sum().item())\n```\n\n**Problem:** Modify the code to compute the mean instead of sum. Print the mean of `result`.\n\n**Expected Output Format:** A single float value rounded to 4 decimal places.',
  'code', 'Easy', 'Machine Learning', 100,
  ARRAY['Use .mean() method on tensors', 'Print with formatting: print(f"{value:.4f}")', 'result.mean().item() gives a Python float'],
  ARRAY['pytorch', 'tensors', 'basic', 'machine-learning'],
  ARRAY['python']
) ON CONFLICT (slug) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'tensorflow-sequential-model',
  'Build a TensorFlow Sequential Model',
  E'**Objective:** Create and compile a neural network with TensorFlow/Keras.\n\n**Task:** Build a simple 2-layer neural network:\n- Input layer: 10 features\n- Hidden layer: 16 units with ReLU activation\n- Output layer: 1 unit with sigmoid activation (binary classification)\n\nCompile with:\n- Optimizer: Adam\n- Loss: Binary Crossentropy\n- Metrics: Accuracy\n\n**Requirements:**\n```python\nfrom tensorflow import keras\nfrom tensorflow.keras import layers\n\nmodel = keras.Sequential([\n    layers.Dense(..., activation=\"...\", input_shape=(...,)),\n    layers.Dense(..., activation=\"...\")\n])\n\nmodel.compile(optimizer=\"...\", loss=\"...\", metrics=[\"...\"])\nprint(model.summary())\n```\n\n**Output:** Print model.summary() to show layer structure.\n\n**Verify:** Your output should show:\n- 2 Dense layers\n- Total trainable parameters',
  'python_code', 'Medium', 'Machine Learning', 150,
  ARRAY['Dense(16, activation="relu", input_shape=(10,)) for hidden layer', 'Dense(1, activation="sigmoid") for binary classification', 'Use keras.Sequential() to stack layers', 'model.summary() prints the architecture'],
  ARRAY['tensorflow', 'keras', 'neural-networks', 'deep-learning'],
  ARRAY['python']
) ON CONFLICT (slug) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'numpy-pandas-analysis',
  'NumPy & Pandas Data Analysis',
  E'**Objective:** Analyze a dataset using NumPy and Pandas.\n\n**Task:** \n```python\nimport numpy as np\nimport pandas as pd\n\n# Create a DataFrame with sample data\ndata = {\n    ''name'': [''Alice'', ''Bob'', ''Charlie'', ''Diana''],\n    ''score'': [85, 92, 78, 95],\n    ''attempts'': [2, 1, 3, 1]\n}\ndf = pd.DataFrame(data)\n\n# Calculate:\n# 1. Mean score\n# 2. Standard deviation of attempts\n# 3. Find the student with highest score\n# 4. Create a new column: efficiency = score / attempts\n```\n\n**Output Format:**\n```\nMean Score: X.XX\nStd Dev Attempts: X.XX\nTop Student: Name (Score)\nEfficiency:\n<efficiency DataFrame>\n```\n\n**Print all required metrics and the modified DataFrame.**',
  'python_code', 'Easy', 'Data Science', 120,
  ARRAY['df[''score''].mean() for mean', 'df[''attempts''].std() for std deviation', 'idxmax() and .loc[] for finding max', 'df[''efficiency''] = df[''score''] / df[''attempts''] to create new column'],
  ARRAY['pandas', 'numpy', 'data-analysis', 'data-science'],
  ARRAY['python']
) ON CONFLICT (slug) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'matplotlib-visualization',
  'Create Data Visualization with Matplotlib',
  E'**Objective:** Generate plots using Matplotlib.\n\n**Task:** Create a visualization showing:\n```python\nimport matplotlib.pyplot as plt\nimport numpy as np\n\n# Data\nx = np.array([1, 2, 3, 4, 5])\ny_linear = 2 * x + 1\ny_quadratic = x ** 2\n\n# Create subplot with 2 plots side by side\nfig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))\n\n# Plot 1: Linear relationship\nax1.plot(x, y_linear, ''b-o'', label=''Linear: y = 2x + 1'')\nax1.set_xlabel(''X'')\nax1.set_ylabel(''Y'')\nax1.set_title(''Linear Function'')\nax1.legend()\nax1.grid(True)\n\n# Plot 2: Quadratic relationship\nax2.plot(x, y_quadratic, ''r-s'', label=''Quadratic: y = x²'')\nax2.set_xlabel(''X'')\nax2.set_ylabel(''Y'')\nax2.set_title(''Quadratic Function'')\nax2.legend()\nax2.grid(True)\n\nplt.tight_layout()\nplt.savefig(''/tmp/ml_plots.png'', dpi=100, bbox_inches=''tight'')\nprint(\"Visualization saved successfully\")\n```\n\n**Output:** Print the message confirming the plot was saved.\n\n**Bonus:** Add a third plot showing both functions together.',
  'python_code', 'Medium', 'Data Science', 140,
  ARRAY['Use plt.subplots() for multiple plots', 'Label axes and add titles', 'Use plt.savefig() to save', 'plt.tight_layout() prevents label overlap', 'Different markers: -o for line+circle, -s for line+square'],
  ARRAY['matplotlib', 'visualization', 'plotting', 'data-science'],
  ARRAY['python']
) ON CONFLICT (slug) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sklearn-train-test-split',
  'Scikit-Learn Model Training & Evaluation',
  E'**Objective:** Train a machine learning model using scikit-learn.\n\n**Task:**\n```python\nfrom sklearn.datasets import load_iris\nfrom sklearn.model_selection import train_test_split\nfrom sklearn.preprocessing import StandardScaler\nfrom sklearn.ensemble import RandomForestClassifier\nfrom sklearn.metrics import accuracy_score, classification_report\n\n# Load iris dataset\niris = load_iris()\nX = iris.data\ny = iris.target\n\n# Split into 80/20 train/test\nX_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)\n\n# Standardize features\nscaler = StandardScaler()\nX_train_scaled = scaler.fit_transform(X_train)\nX_test_scaled = scaler.transform(X_test)\n\n# Train Random Forest\nmodel = RandomForestClassifier(n_estimators=100, random_state=42)\nmodel.fit(X_train_scaled, y_train)\n\n# Evaluate\ny_pred = model.predict(X_test_scaled)\naccuracy = accuracy_score(y_test, y_pred)\n\nprint(f\"Accuracy: {accuracy:.4f}\")\nprint(classification_report(y_test, y_pred))\n```\n\n**Output:** Print the accuracy score and classification report.',
  'python_code', 'Hard', 'Machine Learning', 200,
  ARRAY['Use train_test_split for 80/20 split with random_state=42', 'StandardScaler() normalizes features', 'RandomForestClassifier with 100 estimators', 'accuracy_score() evaluates model', 'classification_report() shows detailed metrics'],
  ARRAY['scikit-learn', 'sklearn', 'classification', 'machine-learning', 'evaluation'],
  ARRAY['python']
) ON CONFLICT (slug) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'pytorch-neural-network-training',
  'Train a Neural Network with PyTorch',
  E'**Objective:** Build and train a neural network end-to-end with PyTorch.\n\n**Task:** Create a simple 2-layer network to learn the XOR function:\n```python\nimport torch\nimport torch.nn as nn\nimport torch.optim as optim\n\n# XOR training data\nX = torch.tensor([[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]])\ny = torch.tensor([[0.0], [1.0], [1.0], [0.0]])\n\n# Define network\nclass XORNet(nn.Module):\n    def __init__(self):\n        super().__init__()\n        self.fc1 = nn.Linear(2, 4)\n        self.fc2 = nn.Linear(4, 1)\n    \n    def forward(self, x):\n        x = torch.relu(self.fc1(x))\n        x = torch.sigmoid(self.fc2(x))\n        return x\n\nmodel = XORNet()\ncriterion = nn.BCELoss()\noptimizer = optim.SGD(model.parameters(), lr=0.5)\n\n# Train for 1000 epochs\nfor epoch in range(1000):\n    optimizer.zero_grad()\n    output = model(X)\n    loss = criterion(output, y)\n    loss.backward()\n    optimizer.step()\n    \n    if (epoch + 1) % 100 == 0:\n        print(f"Epoch {epoch+1}/1000, Loss: {loss.item():.4f}")\n\n# Evaluate\nwith torch.no_grad():\n    predictions = model(X)\n    print(f"\\nFinal Predictions:\\n{predictions}\")\n```\n\n**Output:** Print loss every 100 epochs and final predictions.',
  'python_code', 'Hard', 'Machine Learning', 220,
  ARRAY['Define nn.Module subclass with __init__ and forward()', 'Use nn.Linear for fully connected layers', 'torch.relu for hidden layer, torch.sigmoid for output', 'BCELoss() for binary cross-entropy', 'optimizer.zero_grad(), loss.backward(), optimizer.step() for training loop'],
  ARRAY['pytorch', 'neural-networks', 'training', 'deep-learning'],
  ARRAY['python']
) ON CONFLICT (slug) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'numpy-linear-algebra',
  'NumPy Linear Algebra Operations',
  E'**Objective:** Master NumPy for linear algebra.\n\n**Task:** Perform these operations:\n```python\nimport numpy as np\n\n# Create matrices\nA = np.array([[1, 2], [3, 4]])\nB = np.array([[5, 6], [7, 8]])\n\n# Operations to perform:\n# 1. Matrix multiplication: C = A @ B\n# 2. Transpose: A.T\n# 3. Determinant: np.linalg.det(A)\n# 4. Inverse: np.linalg.inv(A)\n# 5. Eigenvalues and eigenvectors: np.linalg.eig(A)\n# 6. Solve linear system: Ax = b, where b = [1, 2]\n\nC = A @ B\ndet_A = np.linalg.det(A)\ninv_A = np.linalg.inv(A)\neigenvalues, eigenvectors = np.linalg.eig(A)\n\nb = np.array([1, 2])\nx = np.linalg.solve(A, b)\n\nprint(f\"A @ B = \\n{C}\")\nprint(f\"\\ndet(A) = {det_A}\")\nprint(f\"\\ninv(A) = \\n{inv_A}\")\nprint(f\"\\nEigenvalues: {eigenvalues}\")\nprint(f\"\\nSolution to Ax = b: {x}\")\n```\n\n**Output:** Print all results with proper formatting.',
  'python_code', 'Medium', 'Data Science', 160,
  ARRAY['Use @ operator for matrix multiplication', 'np.linalg has det(), inv(), eig(), solve()', '.T for transpose', 'Format output clearly'],
  ARRAY['numpy', 'linear-algebra', 'matrices', 'maths'],
  ARRAY['python']
) ON CONFLICT (slug) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'tensorflow-cnn-mnist',
  'Build a CNN for MNIST with TensorFlow',
  E'**Objective:** Create a Convolutional Neural Network for image classification.\n\n**Task:** Build a CNN that:\n- Takes 28x28 grayscale images (MNIST)\n- Has 2 Conv2D layers (32 and 64 filters)\n- Has a MaxPooling2D layer after each Conv2D\n- Has a Flatten layer\n- Has a Dense layer with 128 units\n- Has an output Dense layer with 10 units (digits 0-9)\n\n```python\nfrom tensorflow import keras\nfrom tensorflow.keras import layers, Sequential\n\nmodel = Sequential([\n    layers.Conv2D(32, (3, 3), activation=\"relu\", input_shape=(28, 28, 1)),\n    layers.MaxPooling2D((2, 2)),\n    layers.Conv2D(64, (3, 3), activation=\"relu\"),\n    layers.MaxPooling2D((2, 2)),\n    layers.Flatten(),\n    layers.Dense(128, activation=\"relu\"),\n    layers.Dropout(0.5),\n    layers.Dense(10, activation=\"softmax\")\n])\n\nmodel.compile(optimizer=\"adam\", loss=\"sparse_categorical_crossentropy\", metrics=[\"accuracy\"])\n\nprint(model.summary())\nprint(f\"Total parameters: {model.count_params()}\")\n```\n\n**Output:** Print model summary and total parameter count.',
  'python_code', 'Expert', 'Machine Learning', 250,
  ARRAY['Conv2D(filters, kernel_size, activation, input_shape)', 'MaxPooling2D reduces spatial dimensions', 'Flatten converts 2D to 1D for Dense layers', 'Dropout(0.5) for regularization', 'softmax activation for multi-class classification'],
  ARRAY['tensorflow', 'keras', 'cnn', 'convolutional-neural-networks', 'deep-learning'],
  ARRAY['python']
) ON CONFLICT (slug) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'pytorch-rnn-sequence',
  'Implement an RNN for Sequence Prediction',
  E'**Objective:** Build a recurrent neural network for time series prediction.\n\n**Task:** Create an LSTM network that predicts the next value in a sequence:\n```python\nimport torch\nimport torch.nn as nn\n\nclass LSTMSequencePredictor(nn.Module):\n    def __init__(self, input_size=1, hidden_size=50, num_layers=2, output_size=1):\n        super().__init__()\n        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)\n        self.fc = nn.Linear(hidden_size, output_size)\n    \n    def forward(self, x):\n        # x shape: (batch_size, sequence_length, input_size)\n        lstm_out, _ = self.lstm(x)\n        # Take last output\n        last_output = lstm_out[:, -1, :]\n        prediction = self.fc(last_output)\n        return prediction\n\nmodel = LSTMSequencePredictor(input_size=1, hidden_size=50, num_layers=2)\n\n# Create dummy sequence\nX = torch.randn(10, 20, 1)  # 10 sequences, length 20, 1 feature\n\noutput = model(X)\nprint(f\"Input shape: {X.shape}\")\nprint(f\"Output shape: {output.shape}\")\nprint(f\"Model parameters: {sum(p.numel() for p in model.parameters())}\")\n```\n\n**Output:** Print input shape, output shape, and total parameters.',
  'python_code', 'Expert', 'Machine Learning', 260,
  ARRAY['nn.LSTM takes input_size, hidden_size, num_layers', 'batch_first=True means (batch, sequence, features)', 'LSTM returns (output, (hidden, cell))', 'Take last time step for prediction', 'nn.Linear maps hidden layer to output'],
  ARRAY['pytorch', 'rnn', 'lstm', 'recurrent-neural-networks', 'sequence-learning'],
  ARRAY['python']
) ON CONFLICT (slug) DO NOTHING;

-- ────────────────────────────────────────────────────────────────────────────
-- Test Cases (inserted after all problems exist)
-- ────────────────────────────────────────────────────────────────────────────

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
SELECT (SELECT id FROM problems WHERE slug='pytorch-tensor-basics'), '', '.*\\d+\\.\\d{4}.*', false, 0
WHERE NOT EXISTS (SELECT 1 FROM problems WHERE slug='pytorch-tensor-basics' LIMIT 0);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
SELECT (SELECT id FROM problems WHERE slug='tensorflow-sequential-model'), '', '.*Dense.*Trainable params.*', false, 0
WHERE NOT EXISTS (SELECT 1 FROM problems WHERE slug='tensorflow-sequential-model' LIMIT 0);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
SELECT (SELECT id FROM problems WHERE slug='numpy-pandas-analysis'), '', '.*Mean Score.*Std Dev.*Top Student.*Efficiency.*', false, 0
WHERE NOT EXISTS (SELECT 1 FROM problems WHERE slug='numpy-pandas-analysis' LIMIT 0);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
SELECT (SELECT id FROM problems WHERE slug='matplotlib-visualization'), '', '.*Visualization saved successfully.*', false, 0
WHERE NOT EXISTS (SELECT 1 FROM problems WHERE slug='matplotlib-visualization' LIMIT 0);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
SELECT (SELECT id FROM problems WHERE slug='sklearn-train-test-split'), '', '.*Accuracy:.*\\d+\\.\\d{4}.*', false, 0
WHERE NOT EXISTS (SELECT 1 FROM problems WHERE slug='sklearn-train-test-split' LIMIT 0);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
SELECT (SELECT id FROM problems WHERE slug='pytorch-neural-network-training'), '', '.*Epoch.*Loss.*Final Predictions.*', false, 0
WHERE NOT EXISTS (SELECT 1 FROM problems WHERE slug='pytorch-neural-network-training' LIMIT 0);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
SELECT (SELECT id FROM problems WHERE slug='numpy-linear-algebra'), '', '.*A @ B.*det\\(A\\).*inv\\(A\\).*Eigenvalues.*Solution.*', false, 0
WHERE NOT EXISTS (SELECT 1 FROM problems WHERE slug='numpy-linear-algebra' LIMIT 0);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
SELECT (SELECT id FROM problems WHERE slug='tensorflow-cnn-mnist'), '', '.*Total parameters.*', false, 0
WHERE NOT EXISTS (SELECT 1 FROM problems WHERE slug='tensorflow-cnn-mnist' LIMIT 0);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order)
SELECT (SELECT id FROM problems WHERE slug='pytorch-rnn-sequence'), '', '.*Input shape.*Output shape.*Model parameters.*', false, 0
WHERE NOT EXISTS (SELECT 1 FROM problems WHERE slug='pytorch-rnn-sequence' LIMIT 0);
