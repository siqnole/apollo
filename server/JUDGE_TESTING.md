# Judge Testing Suite

Comprehensive testing suite for Apollo's answer judging system with edge case validation.

## Overview

This testing suite validates that the answer judging system correctly evaluates student answers while handling various input formats and edge cases.

### Problem Areas Being Tested

1. **Type Coercion**: Numeric answers submitted as `17`, `[17]`, `17.0`, etc.
2. **Normalization**: Whitespace, case sensitivity, decimal precision
3. **Format Variations**: JSON arrays, quoted strings, bare numbers
4. **Cross-Category**: All problem types (fill_blank, multiple_choice, ordering)

## Quick Start

### Run All Tests

```bash
cd server
npm run test:all
```

### Run Specific Test Suites

```bash
# Test enhanced judge with unit tests
npm run test:enhanced

# Test all problems in database with edge cases
npm run test:judge

# Watch mode (auto-rerun on changes)
npm run test:judge:watch
```

## Test Scripts

### 1. `testJudgeEnhanced.ts` - Unit Tests

Pure unit tests for the new enhanced judge implementation. Tests type coercion, normalization, and edge cases.

**Output**: Shows which test cases pass/fail and extracts values from different input formats.

**Key Test Cases**:
- `17` matches `[17]` ✅
- `17` matches `"17"` ❌ (JSON string ≠ number)
- `1.0` matches `1` ✅
- `HELLO` matches `hello` ✅
- `  3  ` matches `3` ✅

### 2. `testJudge.ts` - Integration Tests

Connects to the database and tests all problems with multiple edge case variants.

**Generates Variants For Each Answer**:
- Original value
- Lowercase version
- Uppercase version
- Extra whitespace
- Internal space normalization
- Type variations (array, quoted string)
- Decimal precision variations

**Output**: Detailed report by category showing which edge cases pass/fail.

## Enhanced Judge Features

The new `judgeEnhanced.ts` provides:

```typescript
// Flexible type handling
17 === [17]  // ✅ Array with single number
17 === "17"  // ❌ JSON string is different type
17 === 17.0  // ✅ Decimal precision normalized
```

### Value Extraction Rules

```
Input Format          → Extracted Type & Value
──────────────────────────────────────────────
'17'                  → number: 17
'[17]'                → number: 17
'"17"'                → string: "17"
'17.0'                → number: 17
'-3.14'               → number: -3.14
'hello'               → string: "hello"
'HELLO'               → string: "hello" (lowercased)
'20x^3 - 6x'          → string: "20x^3 - 6x"
```

## Database Schema

These scripts query:

```sql
problems
├── slug
├── problem_type ('fill_blank', 'multiple_choice', 'ordering')
├── title
├── difficulty
├── category
└── hints

test_cases
├── problem_id (FK)
└── expected_output
```

## Interpreting Results

### Passing Test ✅
```
✅ [Easy] limit-direct-substitution (fill_blank)
   All 7 edge cases behaved as expected
```

### Failing Test ❌
```
❌ [Medium] derivative-chain-rule (fill_blank)
   ❌ "As array": should pass but failed
      Input: "[20x^3 - 6x]" | Status: wrong_answer
```

This means an expression wrapped in JSON array notation failed when it should have passed.

## Configuration

### Environment Variables

```bash
DB_USER=postgres
DB_PASSWORD=postgres
DB_HOST=localhost
DB_PORT=5432
DB_NAME=apollo
```

## Roadmap

### Current (Testing)
- ✅ Unit tests for enhanced judge
- ✅ Integration tests with database
- ✅ Edge case variant generation

### Next (Implementation)
- [ ] Swap current judge with enhanced judge
- [ ] Run full suite against production
- [ ] Monitor for regressions

### Future
- [ ] AI-powered answer approximation
- [ ] Mathematical expression parsing
- [ ] Fuzzy matching for typos

## Troubleshooting

### Tests Timeout
Increase timeout in database config:
```typescript
// In testJudge.ts
const pool = new Pool({
  // ...
  connectionTimeoutMillis: 10000,
});
```

### No Test Cases Found
Verify database has active problems:
```sql
SELECT COUNT(*) FROM problems WHERE active = true;
SELECT COUNT(*) FROM test_cases;
```

### Type Errors in Variants
Some problem types (SQL, Shell) use special judging. These are automatically filtered.

## File Structure

```
server/src/
├── services/
│   ├── judge.ts              (Current implementation)
│   └── judgeEnhanced.ts      (New enhanced version with type coercion)
└── utils/
    ├── testJudge.ts          (Integration tests - database + edge cases)
    └── testJudgeEnhanced.ts  (Unit tests - enhanced judge features)
```

## Next Steps

1. Run the unit tests first:
   ```bash
   npm run test:enhanced
   ```

2. Review any failures - these indicate what type coercion rules need adjustment

3. Run integration tests:
   ```bash
   npm run test:judge
   ```

4. When ready to deploy enhanced judge, update [src/routes/problems.ts](../routes/problems.ts#L180) to use `judgeFillBlankEnhanced`

## Example Output

```
🧪 Enhanced Judge Unit Tests

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Exact number match
✅ Exact string match
✅ Number vs array with number
✅ Array vs bare number
✅ Decimal 1.0 vs integer 1
✅ Extra leading whitespace
✅ Lowercase vs uppercase
❌ Quoted vs bare number
   Expected: "17", Got: "17"
   Should pass: false, Result: accepted

📊 Results: 16 passed, 1 failed out of 17 tests
```

## Contributing

When adding new edge cases:

1. Add test case to `testCases` array in [testJudgeEnhanced.ts](./testJudgeEnhanced.ts)
2. Run: `npm run test:enhanced`
3. Update `judgeEnhanced.ts` if logic needs adjustment
4. Re-run to verify

---

**Last Updated**: March 18, 2026
**Status**: Integration tests + unit tests ready, awaiting enhanced judge deployment
