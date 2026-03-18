/**
 * Unit Tests for Enhanced Judge
 * Validates type coercion and edge case handling
 * Usage: ts-node src/utils/testJudgeEnhanced.ts
 */

import {
  judgeFillBlankEnhanced,
  extractValue,
  valuesMatch,
} from '../services/judgeEnhanced';

interface TestCase {
  name: string;
  actual: string;
  expected: string;
  shouldPass: boolean;
}

const testCases: TestCase[] = [
  // Basic exact matches
  { name: 'Exact number match', actual: '3', expected: '3', shouldPass: true },
  { name: 'Exact string match', actual: 'hello', expected: 'hello', shouldPass: true },

  // Type coercion - numbers
  { name: 'Number vs quoted number', actual: '17', expected: '"17"', shouldPass: false }, // JSON string ≠ bare number
  { name: 'Number vs array with number', actual: '17', expected: '[17]', shouldPass: true }, // Should accept!
  { name: 'Array vs bare number', actual: '[17]', expected: '17', shouldPass: true }, // Should accept!
  { name: 'Quoted vs bare number', actual: '"17"', expected: '17', shouldPass: false }, // String ≠ number

  // Decimal variations
  { name: 'Decimal 1.0 vs integer 1', actual: '1', expected: '1.0', shouldPass: true },
  { name: 'Decimal 1.00 vs integer 1', actual: '1.00', expected: '1', shouldPass: true },
  { name: 'Decimal precision', actual: '3.14159', expected: '3.14159', shouldPass: true },

  // Whitespace normalization
  { name: 'Extra leading whitespace', actual: '  3  ', expected: '3', shouldPass: true },
  { name: 'Extra internal whitespace', actual: '3   ', expected: '3', shouldPass: true },
  { name: 'Tab character', actual: '\t3\t', expected: '3', shouldPass: true },

  // Case insensitivity for strings
  { name: 'Lowercase vs uppercase', actual: 'HELLO', expected: 'hello', shouldPass: true },
  { name: 'Mixed case', actual: 'ThE AnSwEr', expected: 'the answer', shouldPass: true },

  // Edge cases from real problems
  { name: 'Calculus limit: 3', actual: '3', expected: '3', shouldPass: true },
  { name: 'Calculus limit: wrong answer', actual: '1', expected: '3', shouldPass: false },
  { name: 'Limit with decimal: 6.0 vs 6', actual: '6.0', expected: '6', shouldPass: true },

  // Negative numbers
  { name: 'Negative number', actual: '-5', expected: '-5', shouldPass: true },
  { name: 'Negative as array', actual: '[-5]', expected: '-5', shouldPass: true },
  { name: 'Negative decimal', actual: '-3.14', expected: '-3.14', shouldPass: true },

  // Zero
  { name: 'Zero', actual: '0', expected: '0', shouldPass: true },
  { name: 'Zero as array', actual: '[0]', expected: '0', shouldPass: true },
  { name: 'Zero decimal', actual: '0.0', expected: '0', shouldPass: true },

  // Different lengths - should fail
  { name: 'Different numbers', actual: '5', expected: '3', shouldPass: false },
  { name: 'Different strings', actual: 'hello', expected: 'world', shouldPass: false },

  // Complex expressions should stay as strings
  { name: 'Expression notation', actual: '20x^3 - 6x', expected: '20x^3 - 6x', shouldPass: true },
  { name: 'Expression case insensitive', actual: '20X^3 - 6X', expected: '20x^3 - 6x', shouldPass: true },
];

function runTests() {
  console.log('🧪 Enhanced Judge Unit Tests\n');
  console.log('━'.repeat(80));

  let passed = 0;
  let failed = 0;
  const failures: string[] = [];

  for (const testCase of testCases) {
    const result = judgeFillBlankEnhanced(testCase.actual, testCase.expected);
    const testPassed =
      testCase.shouldPass === (result.status === 'accepted');

    if (testPassed) {
      console.log(`✅ ${testCase.name}`);
      passed++;
    } else {
      console.log(`❌ ${testCase.name}`);
      console.log(
        `   Expected: "${testCase.expected}", Got: "${testCase.actual}"`
      );
      console.log(
        `   Should pass: ${testCase.shouldPass}, Result: ${result.status}`
      );
      failed++;
      failures.push(testCase.name);
    }
  }

  console.log('\n' + '━'.repeat(80));
  console.log(`\n📊 Results: ${passed} passed, ${failed} failed out of ${testCases.length} tests\n`);

  if (failed > 0) {
    console.log('❌ Failed tests:');
    failures.forEach((f) => console.log(`  • ${f}`));
  } else {
    console.log('✨ All tests passed!');
  }

  console.log();
  return failed === 0;
}

function testValueExtraction() {
  console.log('\n🔍 Value Extraction Tests\n');
  console.log('━'.repeat(80));

  const extractionTests = [
    { input: '17', description: 'Bare number' },
    { input: '"17"', description: 'JSON string' },
    { input: '[17]', description: 'Single-element array' },
    { input: '17.0', description: 'Decimal number' },
    { input: 'hello', description: 'Bare string' },
    { input: '"hello"', description: 'JSON string' },
    { input: '[1, 2, 3]', description: 'Array' },
    { input: '{"key": "value"}', description: 'Object' },
  ];

  for (const test of extractionTests) {
    const extracted = extractValue(test.input);
    console.log(`${test.description}: "${test.input}"`);
    console.log(`  → type: ${extracted.type}, value: ${JSON.stringify(extracted.value)}\n`);
  }
}

// Run all tests
if (runTests()) {
  testValueExtraction();
  process.exit(0);
} else {
  process.exit(1);
}
