-- ════════════════════════════════════════════════════════════════════════════
-- Deduplication Script for problem_options
-- 
-- Issue: Some questions have duplicate answers appearing 3 times each
-- Root cause: ON CONFLICT DO NOTHING doesn't prevent duplicates across multiple
--             INSERTs of the same data (multiple data files loaded in sequence)
-- 
-- Solution: Delete duplicate rows, keeping only one per unique (problem_id, body, display_order)
-- ════════════════════════════════════════════════════════════════════════════

BEGIN TRANSACTION;

-- Step 1: Identify duplicates
-- Show what will be deleted
WITH duplicates AS (
  SELECT 
    p.slug,
    p.title,
    po.body,
    COUNT(*) as duplicate_count,
    ARRAY_AGG(po.id ORDER BY po.id DESC) as all_ids
  FROM problem_options po
  JOIN problems p ON po.problem_id = p.id
  GROUP BY p.id, p.slug, p.title, po.body, po.display_order
  HAVING COUNT(*) > 1
)
SELECT 
  'Duplicates found:' as status,
  slug,
  title,
  body,
  duplicate_count,
  all_ids
FROM duplicates
ORDER BY duplicate_count DESC, slug;

-- Step 2: Delete duplicate rows, keeping the first one (by id) for each unique combination
DELETE FROM problem_options
WHERE id IN (
  SELECT id
  FROM (
    SELECT 
      po.id,
      ROW_NUMBER() OVER (
        PARTITION BY po.problem_id, po.body, po.display_order 
        ORDER BY po.id ASC
      ) as rn
    FROM problem_options po
  ) ranked
  WHERE rn > 1
);

-- Step 3: Verify duplicates are gone
SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ All duplicates removed!'
    ELSE '⚠️  Still have ' || COUNT(*) || ' duplicate groups'
  END as verification
FROM (
  SELECT 
    po.problem_id,
    po.body
  FROM problem_options po
  GROUP BY po.problem_id, po.body
  HAVING COUNT(*) > 1
) still_duplicated;

-- Step 4: Show final counts
SELECT 
  COUNT(*) as total_options,
  COUNT(DISTINCT problem_id) as problems_with_options
FROM problem_options;

COMMIT;
