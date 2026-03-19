-- ── Step 1: Add the missing column ────────────────────────────────────────
ALTER TABLE problems
  ADD COLUMN IF NOT EXISTS supported_languages TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[];

-- ── Step 2: Re-insert problems (using ON CONFLICT to skip if already present)
-- c-malloc-array
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'c-malloc-array',
  'C: Dynamic Array With malloc',
  E'Allocate an integer array of size `n` using `malloc`, fill it with values `1..n`, print each value on its own line, then `free` it.\n\n**Requirements:**\n- Use `malloc` to allocate the array\n- Fill with values 1 through n\n- Print each value on a new line\n- Free the memory before exit\n\n**Example:** n=4 → prints 1, 2, 3, 4 (one per line)',
  'code', 'Easy', 'Systems Programming', 100,
  '{"c":"#include <stdio.h>\n#include <stdlib.h>\n\nint main() {\n    int n;\n    scanf(\"%d\", &n);\n\n    // Allocate, fill, print, free\n    int *arr = /* your malloc here */;\n\n    // fill and print\n\n    free(arr);\n    return 0;\n}"}',
  ARRAY['malloc(n * sizeof(int)) allocates space for n ints', 'Use a for loop to fill: arr[i] = i + 1', 'printf("%d\\n", arr[i]) prints with newline'],
  ARRAY['c','memory','malloc','pointers'],
  ARRAY['c']
)
ON CONFLICT (slug) DO UPDATE
  SET supported_languages = EXCLUDED.supported_languages;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='c-malloc-array'), '4', E'1\n2\n3\n4', false, 0),
((SELECT id FROM problems WHERE slug='c-malloc-array'), '1', '1', true, 1),
((SELECT id FROM problems WHERE slug='c-malloc-array'), '6', E'1\n2\n3\n4\n5\n6', true, 2)
ON CONFLICT DO NOTHING;

-- cpp-stack-class
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'cpp-stack-class',
  'C++: Implement a Stack Class',
  E'Implement a simple stack using a C++ class with:\n- `push(int val)` — pushes a value\n- `pop()` — removes and returns the top value (-1 if empty)\n- `peek()` — returns top without removing (-1 if empty)\n- `isEmpty()` — returns true if empty\n\nRead a sequence of commands from stdin and execute them:\n- `push N` — push integer N\n- `pop` — print the popped value\n- `peek` — print the top value\n\n**Example input:**\n```\npush 5\npush 3\npeek\npop\npop\n```\n**Expected output:**\n```\n3\n3\n5\n```',
  'code', 'Medium', 'Data Structures', 150,
  '{"cpp":"#include <iostream>\n#include <string>\n#include <vector>\nusing namespace std;\n\nclass Stack {\n    // your implementation\npublic:\n    void push(int val) { }\n    int pop() { return -1; }\n    int peek() { return -1; }\n    bool isEmpty() { return true; }\n};\n\nint main() {\n    Stack s;\n    string cmd;\n    while (getline(cin, cmd)) {\n        if (cmd.empty()) continue;\n        if (cmd.substr(0,4) == \"push\") {\n            s.push(stoi(cmd.substr(5)));\n        } else if (cmd == \"pop\") {\n            cout << s.pop() << \"\\n\";\n        } else if (cmd == \"peek\") {\n            cout << s.peek() << \"\\n\";\n        }\n    }\n    return 0;\n}"}',
  ARRAY['Use a std::vector as the underlying storage', 'push_back to push, back() to peek, pop_back to pop', 'Check empty() before popping'],
  ARRAY['cpp','classes','data-structures','stack'],
  ARRAY['cpp']
)
ON CONFLICT (slug) DO UPDATE
  SET supported_languages = EXCLUDED.supported_languages;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='cpp-stack-class'), E'push 5\npush 3\npeek\npop\npop', E'3\n3\n5', false, 0),
((SELECT id FROM problems WHERE slug='cpp-stack-class'), E'push 10\npop\npop', E'10\n-1', true, 1)
ON CONFLICT DO NOTHING;

-- c-reverse-string
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'c-reverse-string',
  'C: Reverse a String In-Place',
  E'Read a string from stdin and print it reversed.\n\nDo **not** use any standard library reverse function. Use pointer arithmetic or array indexing to swap characters in place.\n\n**Example:** `hello` → `olleh`',
  'code', 'Easy', 'Systems Programming', 90,
  '{"c":"#include <stdio.h>\n#include <string.h>\n\nint main() {\n    char s[1024];\n    scanf(\"%s\", s);\n\n    int len = strlen(s);\n    // reverse in place using two pointers\n\n    printf(\"%s\\n\", s);\n    return 0;\n}","cpp":"#include <iostream>\n#include <string>\nusing namespace std;\n\nint main() {\n    string s;\n    cin >> s;\n\n    int len = s.length();\n    // reverse in place using two pointers\n\n    cout << s << \"\\n\";\n    return 0;\n}"}',
  ARRAY['Use two indices: i=0 and j=len-1', 'Swap s[i] and s[j], then i++, j--', 'Stop when i >= j'],
  ARRAY['c','cpp','strings','pointers','two-pointers'],
  ARRAY['c','cpp']
)
ON CONFLICT (slug) DO UPDATE
  SET supported_languages = EXCLUDED.supported_languages;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='c-reverse-string'), 'hello', 'olleh', false, 0),
((SELECT id FROM problems WHERE slug='c-reverse-string'), 'abcde', 'edcba', false, 1),
((SELECT id FROM problems WHERE slug='c-reverse-string'), 'a', 'a', true, 2),
((SELECT id FROM problems WHERE slug='c-reverse-string'), 'racecar', 'racecar', true, 3)
ON CONFLICT DO NOTHING;

-- csharp-linq-filter
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'csharp-linq-filter',
  'C#: Filter and Sum With LINQ',
  E'Read `n` integers from stdin (one per line), then print the **sum of all even numbers** using LINQ.\n\n**Example:**\n```\n5\n1\n2\n3\n4\n6\n```\nOutput: `12` (2 + 4 + 6)',
  'code', 'Easy', 'Languages', 100,
  '{"csharp":"using System;\nusing System.Linq;\nusing System.Collections.Generic;\n\nclass Solution {\n    static void Main(string[] args) {\n        int n = int.Parse(Console.ReadLine());\n        var nums = new List<int>();\n        for (int i = 0; i < n; i++) {\n            nums.Add(int.Parse(Console.ReadLine()));\n        }\n\n        // Use LINQ to filter evens and sum\n        int result = 0; // replace with LINQ\n        Console.WriteLine(result);\n    }\n}"}',
  ARRAY['nums.Where(x => x % 2 == 0) filters evens', '.Sum() computes the total', 'Chain them: nums.Where(...).Sum()'],
  ARRAY['csharp','linq','functional'],
  ARRAY['csharp']
)
ON CONFLICT (slug) DO UPDATE
  SET supported_languages = EXCLUDED.supported_languages;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='csharp-linq-filter'), E'5\n1\n2\n3\n4\n6', '12', false, 0),
((SELECT id FROM problems WHERE slug='csharp-linq-filter'), E'3\n1\n3\n5', '0', false, 1),
((SELECT id FROM problems WHERE slug='csharp-linq-filter'), E'4\n2\n4\n6\n8', '20', true, 2)
ON CONFLICT DO NOTHING;

-- ── Step 3: Re-apply the UPDATE statements from original file ──────────────
UPDATE problems
SET supported_languages = ARRAY['javascript','typescript','python','cpp','c','csharp']
WHERE slug = 'fizzbuzz';

UPDATE problems SET starter_code = starter_code || '{
  "cpp": "#include <iostream>\nusing namespace std;\n\nint main() {\n    int n;\n    cin >> n;\n    for (int i = 1; i <= n; i++) {\n        if (i % 15 == 0) cout << \"FizzBuzz\";\n        else if (i % 3 == 0) cout << \"Fizz\";\n        else if (i % 5 == 0) cout << \"Buzz\";\n        else cout << i;\n        if (i < n) cout << \",\";\n    }\n    cout << endl;\n    return 0;\n}",
  "c": "#include <stdio.h>\n\nint main() {\n    int n;\n    scanf(\"%d\", &n);\n    for (int i = 1; i <= n; i++) {\n        if (i % 15 == 0) printf(\"FizzBuzz\");\n        else if (i % 3 == 0) printf(\"Fizz\");\n        else if (i % 5 == 0) printf(\"Buzz\");\n        else printf(\"%d\", i);\n        if (i < n) printf(\",\");\n    }\n    printf(\"\\n\");\n    return 0;\n}",
  "csharp": "using System;\n\nclass Solution {\n    static void Main(string[] args) {\n        int n = int.Parse(Console.ReadLine());\n        var parts = new System.Collections.Generic.List<string>();\n        for (int i = 1; i <= n; i++) {\n            if (i % 15 == 0) parts.Add(\"FizzBuzz\");\n            else if (i % 3 == 0) parts.Add(\"Fizz\");\n            else if (i % 5 == 0) parts.Add(\"Buzz\");\n            else parts.Add(i.ToString());\n        }\n        Console.WriteLine(\"[\" + string.Join(\",\", parts.ConvertAll(p => \"\\\\\"\"+p+\"\\\\\"\")) + \"]\");\n    }\n}"
}'::jsonb
WHERE slug = 'fizzbuzz';

UPDATE problems
SET supported_languages = ARRAY['javascript','typescript','python','cpp','c','csharp']
WHERE slug IN ('two-sum','binary-search','valid-palindrome');