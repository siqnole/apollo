-- Fix: attention-mechanism expected output
-- Stored value was wrong (1.6517...).
-- Correct answer computed from Q=K=I, V=[[1,2],[3,4]], dk=2:
--   S = QK^T / sqrt(2) = diag(0.7071, 0.7071)
--   softmax weights: [0.6698, 0.3302] and [0.3302, 0.6698]
--   output row 1: 1.6605 2.6605
--   output row 2: 2.3395 3.3395

UPDATE test_cases
SET expected_output = E'1.6605 2.6605\n2.3395 3.3395'
WHERE problem_id = (SELECT id FROM problems WHERE slug = 'attention-mechanism');