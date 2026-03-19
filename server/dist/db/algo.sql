-- ── Sorting & Algorithm Problems ─────────────────────────────────────────
-- Run: psql -U postgres -d apollo -h localhost -f sorting_algorithms.sql

-- ── EASY ──────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'bubble-sort',
  'Bubble Sort',
  E'Implement **bubble sort** from scratch.\n\nRepeatedly step through the array, compare adjacent elements, and swap them if they are in the wrong order. Repeat until the array is sorted.\n\n**Example:**\n```\n[5, 3, 1, 4, 2] → [1, 2, 3, 4, 5]\n```\n\n**Constraints:**\n- Do not use any built-in sort functions\n- Sort in ascending order\n- Input is space-separated integers on one line',
  'code', 'Easy', 'Algorithms', 80,
  '{"javascript":"function bubbleSort(arr) {\n  // your code here\n  return arr;\n}","typescript":"function bubbleSort(arr: number[]): number[] {\n  // your code here\n  return arr;\n}","python":"def bubble_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvector<int> bubbleSort(vector<int> arr) {\n    // your code here\n    return arr;\n}","c":"#include <stdio.h>\nint main() {\n    // read, sort, print\n    return 0;\n}"}',
  ARRAY['Compare arr[i] and arr[i+1], swap if arr[i] > arr[i+1]', 'After each full pass, the largest element bubbles to the end', 'You need n-1 passes for an array of size n', 'Optimization: stop early if no swaps occurred in a pass'],
  ARRAY['sorting', 'bubble-sort', 'classic', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp','c']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='bubble-sort'), '5 3 1 4 2', '1 2 3 4 5', false, 0),
((SELECT id FROM problems WHERE slug='bubble-sort'), '1', '1', false, 1),
((SELECT id FROM problems WHERE slug='bubble-sort'), '9 8 7 6 5 4 3 2 1', '1 2 3 4 5 6 7 8 9', false, 2),
((SELECT id FROM problems WHERE slug='bubble-sort'), '3 3 3', '3 3 3', true, 3),
((SELECT id FROM problems WHERE slug='bubble-sort'), '2 1', '1 2', true, 4)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'selection-sort',
  'Selection Sort',
  E'Implement **selection sort** from scratch.\n\nFind the minimum element from the unsorted portion and place it at the beginning. Repeat for the remaining unsorted portion.\n\n**Example:**\n```\n[64, 25, 12, 22, 11] → [11, 12, 22, 25, 64]\n```\n\n**Constraints:**\n- Do not use any built-in sort functions\n- Sort in ascending order\n- Input is space-separated integers',
  'code', 'Easy', 'Algorithms', 80,
  '{"javascript":"function selectionSort(arr) {\n  // your code here\n  return arr;\n}","typescript":"function selectionSort(arr: number[]): number[] {\n  // your code here\n  return arr;\n}","python":"def selection_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvector<int> selectionSort(vector<int> arr) {\n    // your code here\n    return arr;\n}"}',
  ARRAY['Find the index of the minimum in arr[i..n-1]', 'Swap arr[i] with arr[minIndex]', 'After i iterations, the first i elements are in their final sorted position'],
  ARRAY['sorting', 'selection-sort', 'classic', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='selection-sort'), '64 25 12 22 11', '11 12 22 25 64', false, 0),
((SELECT id FROM problems WHERE slug='selection-sort'), '5 3 1 4 2', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='selection-sort'), '1 2 3', '1 2 3', true, 2),
((SELECT id FROM problems WHERE slug='selection-sort'), '5', '5', true, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'insertion-sort',
  'Insertion Sort',
  E'Implement **insertion sort** from scratch.\n\nBuild the sorted array one element at a time by inserting each new element into its correct position among the already-sorted elements.\n\n**Example:**\n```\n[12, 11, 13, 5, 6] → [5, 6, 11, 12, 13]\n```\n\n**Constraints:**\n- Do not use any built-in sort functions\n- Sort in ascending order\n- Input is space-separated integers',
  'code', 'Easy', 'Algorithms', 80,
  '{"javascript":"function insertionSort(arr) {\n  // your code here\n  return arr;\n}","typescript":"function insertionSort(arr: number[]): number[] {\n  // your code here\n  return arr;\n}","python":"def insertion_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvector<int> insertionSort(vector<int> arr) {\n    // your code here\n    return arr;\n}"}',
  ARRAY['Take element at index i and find where it belongs in arr[0..i-1]', 'Shift elements right to make room', 'Insertion sort is efficient for nearly-sorted arrays'],
  ARRAY['sorting', 'insertion-sort', 'classic', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='insertion-sort'), '12 11 13 5 6', '5 6 11 12 13', false, 0),
((SELECT id FROM problems WHERE slug='insertion-sort'), '5 3 1 4 2', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='insertion-sort'), '1', '1', true, 2),
((SELECT id FROM problems WHERE slug='insertion-sort'), '2 2 2 1', '1 2 2 2', true, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'counting-sort',
  'Counting Sort',
  E'Implement **counting sort** from scratch.\n\nCount the occurrences of each value, then reconstruct the sorted array from those counts. This is a non-comparison sort.\n\n**Example:**\n```\n[4, 2, 2, 8, 3, 3, 1] → [1, 2, 2, 3, 3, 4, 8]\n```\n\n**Constraints:**\n- All values are non-negative integers between 0 and 1000\n- Do not use any built-in sort functions\n- Input is space-separated integers',
  'code', 'Easy', 'Algorithms', 90,
  '{"javascript":"function countingSort(arr) {\n  // your code here\n  return arr;\n}","typescript":"function countingSort(arr: number[]): number[] {\n  // your code here\n  return arr;\n}","python":"def counting_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvector<int> countingSort(vector<int> arr) {\n    // your code here\n    return arr;\n}"}',
  ARRAY['Create a count array of size max+1', 'count[i] = number of times i appears', 'Reconstruct by iterating count and appending i count[i] times'],
  ARRAY['sorting', 'counting-sort', 'non-comparison', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='counting-sort'), '4 2 2 8 3 3 1', '1 2 2 3 3 4 8', false, 0),
((SELECT id FROM problems WHERE slug='counting-sort'), '0 0 1', '0 0 1', false, 1),
((SELECT id FROM problems WHERE slug='counting-sort'), '5', '5', true, 2),
((SELECT id FROM problems WHERE slug='counting-sort'), '10 9 8 7 6', '6 7 8 9 10', true, 3)
ON CONFLICT DO NOTHING;

-- ── MEDIUM ────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'merge-sort',
  'Merge Sort',
  E'Implement **merge sort** from scratch.\n\nDivide the array in half, recursively sort each half, then merge the two sorted halves back together.\n\n**Example:**\n```\n[38, 27, 43, 3, 9, 82, 10] → [3, 9, 10, 27, 38, 43, 82]\n```\n\n**Constraints:**\n- Do not use any built-in sort functions\n- O(n log n) time complexity required\n- Input is space-separated integers',
  'code', 'Medium', 'Algorithms', 130,
  '{"javascript":"function mergeSort(arr) {\n  // your code here\n  return arr;\n}","typescript":"function mergeSort(arr: number[]): number[] {\n  // your code here\n  return arr;\n}","python":"def merge_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvector<int> mergeSort(vector<int> arr) {\n    // your code here\n    return arr;\n}"}',
  ARRAY['Base case: array of length 0 or 1 is already sorted', 'Split: mid = Math.floor(arr.length / 2)', 'Merge two sorted arrays by comparing front elements', 'The merge step is O(n) — do it carefully'],
  ARRAY['sorting', 'merge-sort', 'divide-and-conquer', 'recursion', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='merge-sort'), '38 27 43 3 9 82 10', '3 9 10 27 38 43 82', false, 0),
((SELECT id FROM problems WHERE slug='merge-sort'), '5 3 1 4 2', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='merge-sort'), '1', '1', true, 2),
((SELECT id FROM problems WHERE slug='merge-sort'), '9 8 7 6 5 4 3 2 1', '1 2 3 4 5 6 7 8 9', true, 3),
((SELECT id FROM problems WHERE slug='merge-sort'), '3 3 1 1 2 2', '1 1 2 2 3 3', true, 4)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'quick-sort',
  'Quick Sort',
  E'Implement **quick sort** from scratch.\n\nChoose a pivot, partition the array so elements less than the pivot come before it and elements greater come after, then recursively sort the partitions.\n\n**Example:**\n```\n[10, 7, 8, 9, 1, 5] → [1, 5, 7, 8, 9, 10]\n```\n\n**Constraints:**\n- Do not use any built-in sort functions\n- Average O(n log n) required\n- Input is space-separated integers',
  'code', 'Medium', 'Algorithms', 140,
  '{"javascript":"function quickSort(arr, low = 0, high = arr.length - 1) {\n  // your code here\n  return arr;\n}","typescript":"function quickSort(arr: number[], low = 0, high = arr.length - 1): number[] {\n  // your code here\n  return arr;\n}","python":"def quick_sort(arr, low=0, high=None):\n    if high is None:\n        high = len(arr) - 1\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvoid quickSort(vector<int>& arr, int low, int high) {\n    // your code here\n}\nint main() {\n    // read input, call quickSort, print result\n}"}',
  ARRAY['Choose pivot as last element (or random for better average case)', 'Partition: rearrange so all < pivot are left, all > pivot are right', 'Lomuto partition scheme is simpler to implement', 'Recurse on left and right partitions'],
  ARRAY['sorting', 'quick-sort', 'divide-and-conquer', 'partitioning', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='quick-sort'), '10 7 8 9 1 5', '1 5 7 8 9 10', false, 0),
((SELECT id FROM problems WHERE slug='quick-sort'), '5 3 1 4 2', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='quick-sort'), '1', '1', true, 2),
((SELECT id FROM problems WHERE slug='quick-sort'), '3 3 3', '3 3 3', true, 3),
((SELECT id FROM problems WHERE slug='quick-sort'), '9 8 7 6 5 4 3 2 1', '1 2 3 4 5 6 7 8 9', true, 4)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'heap-sort',
  'Heap Sort',
  E'Implement **heap sort** from scratch.\n\nBuild a max-heap from the array, then repeatedly extract the maximum element to build the sorted array.\n\n**Example:**\n```\n[12, 11, 13, 5, 6, 7] → [5, 6, 7, 11, 12, 13]\n```\n\n**Constraints:**\n- Do not use any built-in sort, heap, or priority queue functions\n- Must be O(n log n) time, O(1) extra space (in-place)\n- Input is space-separated integers',
  'code', 'Medium', 'Algorithms', 150,
  '{"javascript":"function heapSort(arr) {\n  // your code here\n  return arr;\n}","typescript":"function heapSort(arr: number[]): number[] {\n  // your code here\n  return arr;\n}","python":"def heap_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvoid heapSort(vector<int>& arr) {\n    // your code here\n}"}',
  ARRAY['First build a max-heap: for i from n/2-1 down to 0, call heapify(i)', 'Heapify: compare node with children, swap with largest child if needed, recurse', 'Then extract max: swap arr[0] with arr[n-1], reduce heap size, heapify(0)', 'Repeat extraction n-1 times'],
  ARRAY['sorting', 'heap-sort', 'heap', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='heap-sort'), '12 11 13 5 6 7', '5 6 7 11 12 13', false, 0),
((SELECT id FROM problems WHERE slug='heap-sort'), '5 3 1 4 2', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='heap-sort'), '1', '1', true, 2),
((SELECT id FROM problems WHERE slug='heap-sort'), '9 8 7 6 5 4 3 2 1', '1 2 3 4 5 6 7 8 9', true, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'shell-sort',
  'Shell Sort',
  E'Implement **Shell sort** from scratch.\n\nA generalization of insertion sort that allows swapping elements far apart. Start with a large gap, perform gap-insertion sort, then reduce the gap until it is 1.\n\n**Example:**\n```\n[12, 34, 54, 2, 3] → [2, 3, 12, 34, 54]\n```\n\n**Gap sequence:** Use the sequence n/2, n/4, ..., 1 (integer division).\n\n**Constraints:**\n- Do not use built-in sort\n- Input is space-separated integers',
  'code', 'Medium', 'Algorithms', 130,
  '{"javascript":"function shellSort(arr) {\n  // your code here\n  return arr;\n}","typescript":"function shellSort(arr: number[]): number[] {\n  // your code here\n  return arr;\n}","python":"def shell_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvector<int> shellSort(vector<int> arr) {\n    // your code here\n    return arr;\n}"}',
  ARRAY['Start with gap = Math.floor(n/2)', 'For each gap, do insertion sort on elements gap apart', 'Halve the gap each iteration: gap = Math.floor(gap/2)', 'When gap = 1 it becomes regular insertion sort'],
  ARRAY['sorting', 'shell-sort', 'gap-sort', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='shell-sort'), '12 34 54 2 3', '2 3 12 34 54', false, 0),
((SELECT id FROM problems WHERE slug='shell-sort'), '5 3 1 4 2', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='shell-sort'), '1', '1', true, 2),
((SELECT id FROM problems WHERE slug='shell-sort'), '9 8 7 6 5 4 3 2 1', '1 2 3 4 5 6 7 8 9', true, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'gnome-sort',
  'Gnome Sort',
  E'Implement **Gnome sort** (also called Stupid sort) from scratch.\n\nLike insertion sort, but instead of shifting elements, a gnome moves back and forth comparing adjacent pairs:\n- If current element >= previous, move forward\n- If current element < previous, swap and move backward\n\n**Example:**\n```\n[34, 2, 10, -9] → [-9, 2, 10, 34]\n```\n\n**Constraints:**\n- Do not use built-in sort\n- Input is space-separated integers',
  'code', 'Medium', 'Algorithms', 110,
  '{"javascript":"function gnomeSort(arr) {\n  // your code here\n  return arr;\n}","typescript":"function gnomeSort(arr: number[]): number[] {\n  // your code here\n  return arr;\n}","python":"def gnome_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvector<int> gnomeSort(vector<int> arr) {\n    // your code here\n    return arr;\n}"}',
  ARRAY['Start at index 0', 'If index is 0 or arr[index] >= arr[index-1], move forward (index++)', 'Otherwise swap arr[index] and arr[index-1], then move backward (index--)', 'Stop when index reaches end of array'],
  ARRAY['sorting', 'gnome-sort', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='gnome-sort'), '34 2 10 -9', '-9 2 10 34', false, 0),
((SELECT id FROM problems WHERE slug='gnome-sort'), '5 3 1 4 2', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='gnome-sort'), '1', '1', true, 2),
((SELECT id FROM problems WHERE slug='gnome-sort'), '1 2 3', '1 2 3', true, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'cocktail-shaker-sort',
  'Cocktail Shaker Sort',
  E'Implement **Cocktail Shaker sort** (bidirectional bubble sort) from scratch.\n\nLike bubble sort, but alternates between forward and backward passes. Each forward pass bubbles the largest unsorted element to the end; each backward pass bubbles the smallest unsorted element to the front.\n\n**Example:**\n```\n[5, 1, 4, 2, 8, 0, 2] → [0, 1, 2, 2, 4, 5, 8]\n```\n\n**Constraints:**\n- Do not use built-in sort\n- Input is space-separated integers',
  'code', 'Medium', 'Algorithms', 120,
  '{"javascript":"function cocktailSort(arr) {\n  // your code here\n  return arr;\n}","typescript":"function cocktailSort(arr: number[]): number[] {\n  // your code here\n  return arr;\n}","python":"def cocktail_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvector<int> cocktailSort(vector<int> arr) {\n    // your code here\n    return arr;\n}"}',
  ARRAY['Track left and right boundaries that shrink each pass', 'Forward pass: bubble max to right boundary, then right--', 'Backward pass: bubble min to left boundary, then left++', 'Stop when left >= right or no swaps occurred'],
  ARRAY['sorting', 'cocktail-sort', 'bubble-sort', 'bidirectional', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='cocktail-shaker-sort'), '5 1 4 2 8 0 2', '0 1 2 2 4 5 8', false, 0),
((SELECT id FROM problems WHERE slug='cocktail-shaker-sort'), '5 3 1 4 2', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='cocktail-shaker-sort'), '1', '1', true, 2),
((SELECT id FROM problems WHERE slug='cocktail-shaker-sort'), '9 8 7 6 5', '5 6 7 8 9', true, 3)
ON CONFLICT DO NOTHING;

-- ── HARD ──────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'radix-sort',
  'Radix Sort',
  E'Implement **radix sort** (LSD — least significant digit first) from scratch.\n\nSort integers by processing digits from least significant to most significant, using a stable counting sort as a subroutine at each digit position.\n\n**Example:**\n```\n[170, 45, 75, 90, 802, 24, 2, 66] → [2, 24, 45, 66, 75, 90, 170, 802]\n```\n\n**Constraints:**\n- All values are non-negative integers\n- Do not use any built-in sort\n- Must be O(d × (n + k)) where d = digits, k = 10\n- Input is space-separated integers',
  'code', 'Hard', 'Algorithms', 180,
  '{"javascript":"function radixSort(arr) {\n  // your code here\n  return arr;\n}","typescript":"function radixSort(arr: number[]): number[] {\n  // your code here\n  return arr;\n}","python":"def radix_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvector<int> radixSort(vector<int> arr) {\n    // your code here\n    return arr;\n}"}',
  ARRAY['Find max value to determine number of digit passes', 'For each digit position (1, 10, 100, ...): do a stable counting sort by that digit', 'Extract digit: Math.floor(num / exp) % 10', 'Counting sort must be STABLE — preserve relative order of equal digits'],
  ARRAY['sorting', 'radix-sort', 'non-comparison', 'counting-sort', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='radix-sort'), '170 45 75 90 802 24 2 66', '2 24 45 66 75 90 170 802', false, 0),
((SELECT id FROM problems WHERE slug='radix-sort'), '5 3 1 4 2', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='radix-sort'), '100 10 1', '1 10 100', true, 2),
((SELECT id FROM problems WHERE slug='radix-sort'), '0', '0', true, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'bucket-sort',
  'Bucket Sort',
  E'Implement **bucket sort** from scratch for floating point numbers in the range [0, 1).\n\nDistribute elements into n buckets, sort each bucket (using insertion sort), then concatenate.\n\n**Example:**\n```\n[0.897, 0.565, 0.656, 0.123, 0.665, 0.343] → [0.123, 0.343, 0.565, 0.656, 0.665, 0.897]\n```\n\n**Input format:** Space-separated floats, each in [0, 1)\n\n**Output format:** Space-separated floats rounded to 3 decimal places',
  'code', 'Hard', 'Algorithms', 170,
  '{"javascript":"function bucketSort(arr) {\n  // your code here\n  return arr;\n}","typescript":"function bucketSort(arr: number[]): number[] {\n  // your code here\n  return arr;\n}","python":"def bucket_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvector<double> bucketSort(vector<double> arr) {\n    // your code here\n    return arr;\n}"}',
  ARRAY['Create n empty buckets (n = arr.length)', 'Put arr[i] into bucket floor(arr[i] * n)', 'Sort each individual bucket (insertion sort works well)', 'Concatenate all buckets in order'],
  ARRAY['sorting', 'bucket-sort', 'distribution-sort', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='bucket-sort'), '0.897 0.565 0.656 0.123 0.665 0.343', '0.123 0.343 0.565 0.656 0.665 0.897', false, 0),
((SELECT id FROM problems WHERE slug='bucket-sort'), '0.5 0.1 0.9 0.3', '0.1 0.3 0.5 0.9', false, 1),
((SELECT id FROM problems WHERE slug='bucket-sort'), '0.42', '0.42', true, 2)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'timsort',
  'TimSort',
  E'Implement a simplified **TimSort** from scratch.\n\nTimSort is the algorithm used by Python and Java. It divides the array into small runs (use RUN = 32), sorts each with insertion sort, then merges runs using merge sort logic.\n\n**Example:**\n```\n[5, 21, 7, 23, 19, 0, 3, 14, 8, 2] → [0, 2, 3, 5, 7, 8, 14, 19, 21, 23]\n```\n\n**Constraints:**\n- RUN size = 32\n- Use insertion sort on runs\n- Use merge sort merge on combining runs\n- Do not use built-in sort',
  'code', 'Hard', 'Algorithms', 200,
  '{"javascript":"const RUN = 32;\nfunction insertionSort(arr, left, right) {\n  // sort arr[left..right] in place\n}\nfunction merge(arr, left, mid, right) {\n  // merge arr[left..mid] and arr[mid+1..right]\n}\nfunction timSort(arr) {\n  // your code here\n  return arr;\n}","python":"RUN = 32\ndef insertion_sort(arr, left, right):\n    # sort arr[left..right]\n    pass\ndef merge(arr, left, mid, right):\n    # merge arr[left..mid] and arr[mid+1..right]\n    pass\ndef tim_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\n#include <algorithm>\nusing namespace std;\nconst int RUN = 32;\nvoid insertionSort(vector<int>& arr, int left, int right) {}\nvoid merge(vector<int>& arr, int left, int mid, int right) {}\nvoid timSort(vector<int>& arr) {}\nint main() {\n    // read, sort, print\n}"}',
  ARRAY['Step 1: for i in 0..n step RUN, insertion sort arr[i..min(i+RUN-1, n-1)]', 'Step 2: for size in RUN, 2*RUN, 4*RUN... merge adjacent runs', 'Merge boundaries: left=i, mid=i+size-1, right=min(i+2*size-1, n-1)', 'Keep doubling size until size >= n'],
  ARRAY['sorting', 'timsort', 'merge-sort', 'insertion-sort', 'hybrid', 'algorithms'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='timsort'), '5 21 7 23 19 0 3 14 8 2', '0 2 3 5 7 8 14 19 21 23', false, 0),
((SELECT id FROM problems WHERE slug='timsort'), '9 8 7 6 5 4 3 2 1', '1 2 3 4 5 6 7 8 9', false, 1),
((SELECT id FROM problems WHERE slug='timsort'), '1', '1', true, 2),
((SELECT id FROM problems WHERE slug='timsort'), '3 3 1 1 2 2', '1 1 2 2 3 3', true, 3)
ON CONFLICT DO NOTHING;

-- ── EXPERT ────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'bogo-sort',
  'Bogo Sort',
  E'Implement **Bogo sort** (also called permutation sort or monkey sort) from scratch.\n\nRepeatedly shuffle the array randomly until it happens to be sorted. This is intentionally the worst sorting algorithm.\n\n**Complexity:** O((n+1)!) average case — do NOT use this in production.\n\n**Requirements:**\n- Implement `isSorted` to check if the array is sorted\n- Implement `shuffle` using a Fisher-Yates shuffle\n- Repeatedly shuffle until sorted\n\n**Constraints:**\n- Input will have at most **7 elements** (to keep runtime sane)\n- Output the sorted array and the number of shuffles it took\n- Format: sorted elements space-separated on line 1, shuffle count on line 2',
  'code', 'Expert', 'Algorithms', 250,
  '{"javascript":"function isSorted(arr) {\n  // return true if arr is sorted ascending\n}\nfunction shuffle(arr) {\n  // Fisher-Yates shuffle in place\n}\nfunction bogoSort(arr) {\n  let shuffles = 0;\n  while (!isSorted(arr)) {\n    shuffle(arr);\n    shuffles++;\n  }\n  return { sorted: arr, shuffles };\n}","python":"import random\ndef is_sorted(arr):\n    # return True if sorted\n    pass\ndef bogo_sort(arr):\n    shuffles = 0\n    while not is_sorted(arr):\n        random.shuffle(arr)\n        shuffles += 1\n    return arr, shuffles","cpp":"#include <vector>\n#include <algorithm>\n#include <random>\nusing namespace std;\nbool isSorted(const vector<int>& arr) {\n    // check if sorted\n}\nvoid shuffleArr(vector<int>& arr) {\n    // Fisher-Yates\n}\nint main() {\n    // read, bogo sort, print sorted + shuffle count\n}"}',
  ARRAY['isSorted: check arr[i] <= arr[i+1] for all i', 'Fisher-Yates: for i from n-1 down to 1, swap arr[i] with arr[random(0..i)]', 'Since output includes shuffle count which is random, the judge checks only that the output is sorted', 'With 7 elements, average shuffles is 7! / 2 = 2520 — it will terminate'],
  ARRAY['sorting', 'bogo-sort', 'joke-sort', 'randomized', 'expert', 'algorithms'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='bogo-sort'), '3 1 2', '1 2 3', false, 0),
((SELECT id FROM problems WHERE slug='bogo-sort'), '5 4 3 2 1', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='bogo-sort'), '1', '1', true, 2),
((SELECT id FROM problems WHERE slug='bogo-sort'), '7 6 5 4 3 2 1', '1 2 3 4 5 6 7', true, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'stalin-sort',
  'Stalin Sort',
  E'Implement **Stalin sort** from scratch.\n\nStalin sort "sorts" an array by removing any element that is out of order. Walk through the array once; if an element is less than the current maximum, eliminate it. What remains is sorted (ascending).\n\n**Example:**\n```\n[1, 9, 2, 8, 3, 7] → [1, 9] removed: [2, 8, 3, 7]\nWait — keep elements >= previous kept element:\n[1, 9, 2, 8, 3, 7] → [1, 9]  (2, 8, 3, 7 all removed since they are < 9)\n```\n\n**More examples:**\n```\n[1, 2, 3, 1, 5] → [1, 2, 3, 5]  (1 removed)\n[5, 1, 2, 3, 4] → [5]           (1,2,3,4 removed)\n[1, 2, 3, 4, 5] → [1, 2, 3, 4, 5] (nothing removed)\n```\n\n**Output:** The "sorted" (purged) array, space-separated.',
  'code', 'Expert', 'Algorithms', 200,
  '{"javascript":"function stalinSort(arr) {\n  // your code here — remove elements that break ascending order\n  return arr;\n}","typescript":"function stalinSort(arr: number[]): number[] {\n  // your code here\n  return arr;\n}","python":"def stalin_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\nusing namespace std;\nvector<int> stalinSort(vector<int> arr) {\n    // your code here\n    return arr;\n}"}',
  ARRAY['Keep a running maximum', 'Include an element only if it is >= the current maximum', 'Update the maximum whenever you keep an element', 'This is O(n) time — one pass'],
  ARRAY['sorting', 'stalin-sort', 'joke-sort', 'filter', 'expert', 'algorithms'],
  ARRAY['javascript','typescript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='stalin-sort'), '1 2 3 1 5', '1 2 3 5', false, 0),
((SELECT id FROM problems WHERE slug='stalin-sort'), '5 1 2 3 4', '5', false, 1),
((SELECT id FROM problems WHERE slug='stalin-sort'), '1 2 3 4 5', '1 2 3 4 5', false, 2),
((SELECT id FROM problems WHERE slug='stalin-sort'), '1 9 2 8 3 7', '1 9', true, 3),
((SELECT id FROM problems WHERE slug='stalin-sort'), '3', '3', true, 4)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'sleep-sort',
  'Sleep Sort',
  E'Implement **Sleep sort** from scratch.\n\nSleep sort is a joke sorting algorithm: spawn a thread/timer for each element with a delay proportional to its value. Each thread appends its value to the result when it wakes up.\n\n**Requirements:**\n- Each element `x` sleeps for `x * 10` milliseconds before being added to result\n- Elements with equal values may appear in any order\n- Return a Promise (JS) or use threading (Python) to collect results\n\n**Example:**\n```\n[3, 1, 4, 1, 5] → [1, 1, 3, 4, 5]\n```\n\n**Constraints:**\n- Input values are positive integers 1–20\n- JavaScript/TypeScript only (async/await + setTimeout)',
  'code', 'Expert', 'Algorithms', 220,
  '{"javascript":"function sleepSort(arr) {\n  return new Promise((resolve) => {\n    const result = [];\n    let done = 0;\n    for (const x of arr) {\n      setTimeout(() => {\n        result.push(x);\n        done++;\n        if (done === arr.length) resolve(result);\n      }, x * 10);\n    }\n  });\n}\n// Entry point:\nasync function main() {\n  // read input, call sleepSort, print result\n}","typescript":"function sleepSort(arr: number[]): Promise<number[]> {\n  return new Promise((resolve) => {\n    const result: number[] = [];\n    let done = 0;\n    for (const x of arr) {\n      setTimeout(() => {\n        result.push(x);\n        done++;\n        if (done === arr.length) resolve(result);\n      }, x * 10);\n    }\n  });\n}"}',
  ARRAY['Use setTimeout with delay = x * 10 milliseconds', 'Track how many timers have fired with a counter', 'Resolve the Promise when all timers have fired', 'Elements that wake at the same time can be in any order'],
  ARRAY['sorting', 'sleep-sort', 'joke-sort', 'async', 'concurrency', 'expert', 'algorithms'],
  ARRAY['javascript','typescript']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='sleep-sort'), '3 1 4 1 5', '1 1 3 4 5', false, 0),
((SELECT id FROM problems WHERE slug='sleep-sort'), '5 2 8 1', '1 2 5 8', false, 1),
((SELECT id FROM problems WHERE slug='sleep-sort'), '1', '1', true, 2)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'introsort',
  'Introsort',
  E'Implement **Introsort** from scratch — the hybrid algorithm used by C++ STL `std::sort`.\n\nIntrosort starts with quicksort but switches to heapsort when recursion depth exceeds `2 × floor(log2(n))` to guarantee O(n log n) worst case. Switch to insertion sort for subarrays of size ≤ 16.\n\n**Algorithm:**\n1. If size ≤ 16: insertion sort\n2. If depth == 0: heap sort\n3. Otherwise: quicksort partition, recurse with depth-1\n\n**Example:**\n```\n[8, 4, 2, 9, 1, 3, 7, 5, 6] → [1, 2, 3, 4, 5, 6, 7, 8, 9]\n```',
  'code', 'Expert', 'Algorithms', 300,
  '{"javascript":"function insertionSort(arr, lo, hi) { /* sort arr[lo..hi] */ }\nfunction heapSort(arr, lo, hi) { /* heap sort arr[lo..hi] */ }\nfunction partition(arr, lo, hi) { /* lomuto partition, return pivot index */ }\nfunction introsortUtil(arr, lo, hi, depth) {\n  if (hi - lo < 16) { insertionSort(arr, lo, hi); return; }\n  if (depth === 0) { heapSort(arr, lo, hi); return; }\n  const p = partition(arr, lo, hi);\n  introsortUtil(arr, lo, p - 1, depth - 1);\n  introsortUtil(arr, p + 1, hi, depth - 1);\n}\nfunction introsort(arr) {\n  const depth = 2 * Math.floor(Math.log2(arr.length));\n  introsortUtil(arr, 0, arr.length - 1, depth);\n  return arr;\n}","python":"import math\ndef insertion_sort(arr, lo, hi): pass\ndef heap_sort(arr, lo, hi): pass\ndef partition(arr, lo, hi): pass\ndef introsort_util(arr, lo, hi, depth):\n    if hi - lo < 16:\n        insertion_sort(arr, lo, hi); return\n    if depth == 0:\n        heap_sort(arr, lo, hi); return\n    p = partition(arr, lo, hi)\n    introsort_util(arr, lo, p - 1, depth - 1)\n    introsort_util(arr, p + 1, hi, depth - 1)\ndef introsort(arr):\n    depth = 2 * int(math.log2(len(arr))) if len(arr) > 1 else 0\n    introsort_util(arr, 0, len(arr) - 1, depth)\n    return arr","cpp":"#include <vector>\n#include <cmath>\nusing namespace std;\nvoid insertionSort(vector<int>& arr, int lo, int hi) {}\nvoid heapSort(vector<int>& arr, int lo, int hi) {}\nint partition(vector<int>& arr, int lo, int hi) { return lo; }\nvoid introsortUtil(vector<int>& arr, int lo, int hi, int depth) {\n    if (hi - lo < 16) { insertionSort(arr, lo, hi); return; }\n    if (depth == 0) { heapSort(arr, lo, hi); return; }\n    int p = partition(arr, lo, hi);\n    introsortUtil(arr, lo, p - 1, depth - 1);\n    introsortUtil(arr, p + 1, hi, depth - 1);\n}\nvoid introsort(vector<int>& arr) {\n    int depth = arr.size() > 1 ? 2 * (int)log2(arr.size()) : 0;\n    introsortUtil(arr, 0, arr.size() - 1, depth);\n}"}',
  ARRAY['Implement all three sub-sorts first: insertion, heap, quicksort partition', 'Depth limit = 2 * floor(log2(n)) — tracks recursion depth remaining', 'When depth hits 0, fall back to heapsort to avoid O(n²) worst case', 'Threshold of 16 for insertion sort is standard — small arrays are fast with insertion sort'],
  ARRAY['sorting', 'introsort', 'hybrid', 'quicksort', 'heapsort', 'expert', 'algorithms'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='introsort'), '8 4 2 9 1 3 7 5 6', '1 2 3 4 5 6 7 8 9', false, 0),
((SELECT id FROM problems WHERE slug='introsort'), '5 3 1 4 2', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='introsort'), '9 8 7 6 5 4 3 2 1', '1 2 3 4 5 6 7 8 9', true, 2),
((SELECT id FROM problems WHERE slug='introsort'), '1', '1', true, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'pancake-sort',
  'Pancake Sort',
  E'Implement **Pancake sort** from scratch.\n\nThe only allowed operation is a **prefix flip**: reverse the first `k` elements of the array. Sort the array using only prefix flips.\n\n**Example:**\n```\n[3, 2, 4, 1] → flip(3) → [4, 2, 3, 1] → flip(4) → [1, 3, 2, 4] → ...\n```\n\n**Strategy:** For each position from n down to 2:\n1. Find the index of the maximum in arr[0..i]\n2. Flip to bring max to front (if not already)\n3. Flip to bring max to position i\n\n**Output:** The sorted array.\n\n**Constraints:** Input is space-separated integers.',
  'code', 'Expert', 'Algorithms', 260,
  '{"javascript":"function flip(arr, k) {\n  // reverse arr[0..k-1] in place\n}\nfunction pancakeSort(arr) {\n  // your code here\n  return arr;\n}","python":"def flip(arr, k):\n    # reverse arr[0..k-1] in place\n    pass\ndef pancake_sort(arr):\n    # your code here\n    return arr","cpp":"#include <vector>\n#include <algorithm>\nusing namespace std;\nvoid flip(vector<int>& arr, int k) {\n    reverse(arr.begin(), arr.begin() + k);\n}\nvoid pancakeSort(vector<int>& arr) {\n    // your code here\n}"}',
  ARRAY['flip(k) reverses arr[0..k-1]', 'Find index of max in arr[0..i-1] using a linear scan', 'If max is not at index 0, flip(maxIndex+1) to bring it to front', 'Then flip(i) to send it to its final position at index i-1'],
  ARRAY['sorting', 'pancake-sort', 'prefix-flip', 'expert', 'algorithms'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='pancake-sort'), '3 2 4 1', '1 2 3 4', false, 0),
((SELECT id FROM problems WHERE slug='pancake-sort'), '5 3 1 4 2', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='pancake-sort'), '1', '1', true, 2),
((SELECT id FROM problems WHERE slug='pancake-sort'), '9 8 7 6 5 4 3 2 1', '1 2 3 4 5 6 7 8 9', true, 3)
ON CONFLICT DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────

INSERT INTO problems (slug, title, description, problem_type, difficulty, category, xp_reward, starter_code, hints, tags, supported_languages)
VALUES (
  'cycle-sort',
  'Cycle Sort',
  E'Implement **Cycle sort** from scratch — the sorting algorithm that makes the **minimum number of writes** to the array.\n\nDecompose the array into cycles, then rotate each cycle to sort it. This is optimal for minimizing memory writes.\n\n**Example:**\n```\n[10, 5, 2, 3] → [2, 3, 5, 10]  (3 writes)\n```\n\n**Constraints:**\n- Count and output the number of writes made\n- Format: sorted array on line 1, write count on line 2\n- Input is space-separated distinct integers',
  'code', 'Expert', 'Algorithms', 280,
  '{"javascript":"function cycleSort(arr) {\n  let writes = 0;\n  for (let cycleStart = 0; cycleStart < arr.length - 1; cycleStart++) {\n    let item = arr[cycleStart];\n    // find where item belongs\n    let pos = cycleStart;\n    for (let i = cycleStart + 1; i < arr.length; i++)\n      if (arr[i] < item) pos++;\n    if (pos === cycleStart) continue;\n    // skip duplicates\n    while (item === arr[pos]) pos++;\n    // put item in its right position\n    [arr[pos], item] = [item, arr[pos]];\n    writes++;\n    // rotate rest of cycle\n    while (pos !== cycleStart) {\n      pos = cycleStart;\n      for (let i = cycleStart + 1; i < arr.length; i++)\n        if (arr[i] < item) pos++;\n      while (item === arr[pos]) pos++;\n      [arr[pos], item] = [item, arr[pos]];\n      writes++;\n    }\n  }\n  return { sorted: arr, writes };\n}","python":"def cycle_sort(arr):\n    writes = 0\n    for cycle_start in range(len(arr) - 1):\n        item = arr[cycle_start]\n        pos = cycle_start\n        for i in range(cycle_start + 1, len(arr)):\n            if arr[i] < item:\n                pos += 1\n        if pos == cycle_start:\n            continue\n        while item == arr[pos]:\n            pos += 1\n        arr[pos], item = item, arr[pos]\n        writes += 1\n        while pos != cycle_start:\n            pos = cycle_start\n            for i in range(cycle_start + 1, len(arr)):\n                if arr[i] < item:\n                    pos += 1\n            while item == arr[pos]:\n                pos += 1\n            arr[pos], item = item, arr[pos]\n            writes += 1\n    return arr, writes","cpp":"#include <vector>\nusing namespace std;\npair<vector<int>,int> cycleSort(vector<int> arr) {\n    int writes = 0;\n    // implement cycle sort\n    return {arr, writes};\n}"}',
  ARRAY['For each starting position, find where the element belongs by counting smaller elements', 'That defines one "cycle" — rotate the cycle until cycleStart element is placed', 'Count each write (placement into final or temporary position)', 'Cycle sort is unique: minimum writes = n - number of cycles'],
  ARRAY['sorting', 'cycle-sort', 'minimum-writes', 'expert', 'algorithms'],
  ARRAY['javascript','python','cpp']
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO test_cases (problem_id, input, expected_output, is_hidden, display_order) VALUES
((SELECT id FROM problems WHERE slug='cycle-sort'), '10 5 2 3', '2 3 5 10', false, 0),
((SELECT id FROM problems WHERE slug='cycle-sort'), '5 3 1 4 2', '1 2 3 4 5', false, 1),
((SELECT id FROM problems WHERE slug='cycle-sort'), '1 2 3', '1 2 3', true, 2),
((SELECT id FROM problems WHERE slug='cycle-sort'), '4 3 2 1', '1 2 3 4', true, 3)
ON CONFLICT DO NOTHING;

-- ── Update supported_languages for all new problems ───────────────────────
UPDATE problems SET supported_languages = ARRAY['javascript','typescript','python','cpp','c']
WHERE slug IN ('bubble-sort','selection-sort','insertion-sort','counting-sort','merge-sort','quick-sort','heap-sort','shell-sort','gnome-sort','cocktail-shaker-sort','radix-sort','bucket-sort','timsort','bogo-sort','stalin-sort','sleep-sort','introsort','pancake-sort','cycle-sort');