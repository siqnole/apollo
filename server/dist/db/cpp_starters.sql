-- Update C/C++/C# starter code for existing problems to include main()

UPDATE problems SET starter_code = starter_code || '{
  "cpp": "#include <iostream>\n#include <vector>\n#include <sstream>\nusing namespace std;\n\nint main() {\n    // Parse input: first line is array, second is target\n    string line;\n    getline(cin, line);\n    // your solution here\n    return 0;\n}",
  "c": "#include <stdio.h>\n#include <stdlib.h>\n\nint main() {\n    // Read input, solve, print output\n    // your solution here\n    return 0;\n}",
  "csharp": "using System;\n\nclass Solution {\n    static void Main(string[] args) {\n        // Read input with Console.ReadLine()\n        // your solution here\n    }\n}"
}'::jsonb
WHERE problem_type IN ('code', 'debug')
  AND (starter_code->>'cpp' IS NULL OR starter_code->>'c' IS NULL);