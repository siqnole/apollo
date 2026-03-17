-- Sample problems across different types and categories

-- 1. Code: Two Sum
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags)
VALUES (
  'two-sum',
  'Two Sum',
  E'Given an array of integers `nums` and an integer `target`, return the **indices** of the two numbers that add up to `target`.\n\nYou may assume each input has exactly one solution. You may not use the same element twice.\n\n**Example:**\n```\nnums = [2, 7, 11, 15], target = 9\nOutput: [0, 1]  // nums[0] + nums[1] = 2 + 7 = 9\n```',
  'code', 'Easy', 'Algorithms', 100,
  '{"javascript":"function twoSum(nums, target) {\n  // your code here\n}","typescript":"function twoSum(nums: number[], target: number): number[] {\n  // your code here\n  return [];\n}","python":"def two_sum(nums, target):\n    # your code here\n    pass","cpp":"#include <vector>\nusing namespace std;\nvector<int> twoSum(vector<int>& nums, int target) {\n    // your code here\n    return {};\n}","c":"// C solution\n#include <stdlib.h>\nint* twoSum(int* nums, int numsSize, int target, int* returnSize) {\n    // your code here\n    return NULL;\n}","csharp":"public class Solution {\n    public int[] TwoSum(int[] nums, int target) {\n        // your code here\n        return new int[] {};\n    }\n}"}',
  ARRAY['Try using a hash map for O(n) time', 'For each number, check if target - number exists in the map'],
  ARRAY['arrays', 'hash-map', 'classic']
);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='two-sum'), '[2,7,11,15]\n9', '[0,1]', false, 0),
((SELECT id FROM problems WHERE slug='two-sum'), '[3,2,4]\n6', '[1,2]', false, 1),
((SELECT id FROM problems WHERE slug='two-sum'), '[3,3]\n6', '[0,1]', true, 2),
((SELECT id FROM problems WHERE slug='two-sum'), '[1,5,3,7,2]\n9', '[1,3]', true, 3);

-- 2. Code: Palindrome Check
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags)
VALUES (
  'valid-palindrome',
  'Valid Palindrome',
  E'A string is a palindrome if it reads the same forwards and backwards, ignoring case and non-alphanumeric characters.\n\nReturn `true` if the string is a palindrome, `false` otherwise.\n\n**Examples:**\n```\n"A man, a plan, a canal: Panama" → true\n"race a car" → false\n" " → true\n```',
  'code', 'Easy', 'Strings', 75,
  '{"javascript":"function isPalindrome(s) {\n  // your code here\n}","typescript":"function isPalindrome(s: string): boolean {\n  // your code here\n  return false;\n}","python":"def is_palindrome(s: str) -> bool:\n    # your code here\n    pass","cpp":"#include <string>\nbool isPalindrome(std::string s) {\n    // your code here\n    return false;\n}"}',
  ARRAY['Strip non-alphanumeric characters first', 'Use two pointers from both ends'],
  ARRAY['strings', 'two-pointers']
);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='valid-palindrome'), '"A man, a plan, a canal: Panama"', 'true', false, 0),
((SELECT id FROM problems WHERE slug='valid-palindrome'), '"race a car"', 'false', false, 1),
((SELECT id FROM problems WHERE slug='valid-palindrome'), '" "', 'true', true, 2);

-- 3. Multiple Choice: Big O
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags)
VALUES (
  'big-o-binary-search',
  'Time Complexity of Binary Search',
  E'What is the **time complexity** of binary search on a sorted array of `n` elements?',
  'multiple_choice', 'Easy', 'Computer Science', 50,
  ARRAY['Think about how many elements are eliminated per step'],
  ARRAY['big-o', 'algorithms', 'theory']
);

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='big-o-binary-search'), 'A', 'O(1)', false, 0),
((SELECT id FROM problems WHERE slug='big-o-binary-search'), 'B', 'O(log n)', true, 1),
((SELECT id FROM problems WHERE slug='big-o-binary-search'), 'C', 'O(n)', false, 2),
((SELECT id FROM problems WHERE slug='big-o-binary-search'), 'D', 'O(n log n)', false, 3);

-- 4. Multiple Choice: HTTP Methods
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, tags)
VALUES (
  'http-idempotent-methods',
  'HTTP Idempotent Methods',
  E'Which of the following HTTP methods is **NOT** idempotent?\n\n> An idempotent method can be called multiple times with the same result.',
  'multiple_choice', 'Medium', 'Web Development', 60,
  ARRAY['http', 'rest', 'web']
);

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='http-idempotent-methods'), 'A', 'GET', false, 0),
((SELECT id FROM problems WHERE slug='http-idempotent-methods'), 'B', 'PUT', false, 1),
((SELECT id FROM problems WHERE slug='http-idempotent-methods'), 'C', 'DELETE', false, 2),
((SELECT id FROM problems WHERE slug='http-idempotent-methods'), 'D', 'POST', true, 3);

-- 5. Debug: Fix the loop
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags)
VALUES (
  'debug-off-by-one',
  'Debug: Off-by-One Error',
  E'The function below should return the **sum of all numbers from 1 to n** (inclusive).\n\nIt has a bug. Find and fix it.\n\n```javascript\nfunction sumToN(n) {\n  let sum = 0;\n  for (let i = 0; i < n; i++) {\n    sum += i;\n  }\n  return sum;\n}\n```',
  'debug', 'Easy', 'Debugging', 75,
  '{"javascript":"function sumToN(n) {\n  let sum = 0;\n  for (let i = 0; i < n; i++) {\n    sum += i;\n  }\n  return sum;\n}","typescript":"function sumToN(n: number): number {\n  let sum = 0;\n  for (let i = 0; i < n; i++) {\n    sum += i;\n  }\n  return sum;\n}","python":"def sum_to_n(n):\n    total = 0\n    for i in range(n):\n        total += i\n    return total"}',
  ARRAY['Should 1+2+3 = 6 for n=3?', 'Check the loop bounds and what i starts at'],
  ARRAY['debugging', 'loops', 'off-by-one']
);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='debug-off-by-one'), '3', '6', false, 0),
((SELECT id FROM problems WHERE slug='debug-off-by-one'), '5', '15', false, 1),
((SELECT id FROM problems WHERE slug='debug-off-by-one'), '10', '55', true, 2),
((SELECT id FROM problems WHERE slug='debug-off-by-one'), '1', '1', true, 3);

-- 6. Fill in the blank: SQL
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags)
VALUES (
  'sql-fill-join',
  'Complete the SQL JOIN',
  E'Fill in the blanks to complete this SQL query that retrieves all users and their orders (including users with no orders):\n\n```sql\nSELECT users.name, orders.total\nFROM users\n_____ JOIN orders ON users.id = orders.user_id;\n```\n\nEnter just the missing keyword.',
  'fill_blank', 'Easy', 'Databases', 50,
  ARRAY['There are four types of JOINs', 'We want ALL users even those without orders'],
  ARRAY['sql', 'joins', 'databases']
);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='sql-fill-join'), '', 'LEFT', false, 0);

-- 7. Ordering: CSS Box Model
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, tags)
VALUES (
  'css-box-model-order',
  'CSS Box Model Layers',
  E'Arrange the layers of the **CSS Box Model** from innermost to outermost.',
  'ordering', 'Easy', 'Web Development', 50,
  ARRAY['html', 'css', 'box-model']
);

INSERT INTO problem_options (problem_id, label, body, is_correct, display_order) VALUES
((SELECT id FROM problems WHERE slug='css-box-model-order'), '1', 'Content', true, 0),
((SELECT id FROM problems WHERE slug='css-box-model-order'), '2', 'Padding', true, 1),
((SELECT id FROM problems WHERE slug='css-box-model-order'), '3', 'Border', true, 2),
((SELECT id FROM problems WHERE slug='css-box-model-order'), '4', 'Margin', true, 3);

-- 8. Code: FizzBuzz (classic warm-up)
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, tags)
VALUES (
  'fizzbuzz',
  'FizzBuzz',
  E'Write a function that returns an array of strings for numbers 1 to `n`:\n- `"Fizz"` for multiples of 3\n- `"Buzz"` for multiples of 5\n- `"FizzBuzz"` for multiples of both\n- The number itself (as a string) otherwise\n\n**Example:** `fizzBuzz(5)` → `["1","2","Fizz","4","Buzz"]`',
  'code', 'Easy', 'Algorithms', 50,
  '{"javascript":"function fizzBuzz(n) {\n  // your code here\n  return [];\n}","typescript":"function fizzBuzz(n: number): string[] {\n  // your code here\n  return [];\n}","python":"def fizz_buzz(n):\n    # your code here\n    pass","cpp":"#include <vector>\n#include <string>\nvector<string> fizzBuzz(int n) {\n    // your code here\n    return {};\n}"}',
  ARRAY['arrays', 'classic', 'warmup']
);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='fizzbuzz'), '5', '["1","2","Fizz","4","Buzz"]', false, 0),
((SELECT id FROM problems WHERE slug='fizzbuzz'), '15', '["1","2","Fizz","4","Buzz","Fizz","7","8","Fizz","Buzz","11","Fizz","13","14","FizzBuzz"]', false, 1),
((SELECT id FROM problems WHERE slug='fizzbuzz'), '1', '["1"]', true, 2);

-- 9. Code: Binary Search
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags)
VALUES (
  'binary-search',
  'Binary Search',
  E'Given a sorted array of integers and a target value, return the **index** of the target using binary search. Return `-1` if not found.\n\nYou must achieve O(log n) runtime.\n\n**Example:**\n```\nnums = [-1, 0, 3, 5, 9, 12], target = 9 → 4\nnums = [-1, 0, 3, 5, 9, 12], target = 2 → -1\n```',
  'code', 'Easy', 'Algorithms', 75,
  '{"javascript":"function search(nums, target) {\n  // your code here\n  return -1;\n}","typescript":"function search(nums: number[], target: number): number {\n  // your code here\n  return -1;\n}","python":"def search(nums, target):\n    # your code here\n    return -1","cpp":"#include <vector>\nint search(std::vector<int>& nums, int target) {\n    // your code here\n    return -1;\n}"}',
  ARRAY['Start with left=0 and right=n-1', 'Calculate mid = Math.floor((left+right)/2)', 'Eliminate half the array each iteration'],
  ARRAY['binary-search', 'arrays', 'classic']
);

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='binary-search'), '[-1,0,3,5,9,12]\n9', '4', false, 0),
((SELECT id FROM problems WHERE slug='binary-search'), '[-1,0,3,5,9,12]\n2', '-1', false, 1),
((SELECT id FROM problems WHERE slug='binary-search'), '[5]\n5', '0', true, 2),
((SELECT id FROM problems WHERE slug='binary-search'), '[1,3,5,7,9,11]\n7', '3', true, 3);

-- 10. Short Answer: Explain recursion
INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, hints, tags)
VALUES (
  'explain-recursion',
  'Explain Recursion',
  E'In your own words, explain what **recursion** is and what two components every recursive function must have.\n\nWrite 2-4 sentences.',
  'short_answer', 'Easy', 'Computer Science', 40,
  ARRAY['Think about a function calling itself', 'What stops it from running forever?'],
  ARRAY['recursion', 'theory', 'cs-fundamentals']
);