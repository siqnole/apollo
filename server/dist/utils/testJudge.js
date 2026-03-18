"use strict";
/**
 * Comprehensive Test Suite for Answer Judgement
 * Tests all problems with edge cases for type handling and normalization
 * Usage: ts-node src/utils/testJudge.ts
 */
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const pg_1 = require("pg");
const judge_1 = require("../services/judge");
// Use DATABASE_URL if set, otherwise construct from components
const connectionString = process.env.DATABASE_URL ||
    `postgresql://${process.env.DB_USER || 'postgres'}:${process.env.DB_PASSWORD || 'postgres'}@${process.env.DB_HOST || 'localhost'}:${process.env.DB_PORT || '5432'}/${process.env.DB_NAME || 'apollo'}`;
const pool = new pg_1.Pool({
    connectionString,
    connectionTimeoutMillis: 10000,
});
/**
 * Generate edge case variants for a given answer
 */
function generateEdgeCases(answer, problemType) {
    const variants = [
        { label: 'Original', value: answer, shouldPass: true },
        { label: 'Lowercase', value: answer.toLowerCase(), shouldPass: true },
        { label: 'Uppercase', value: answer.toUpperCase(), shouldPass: true },
        { label: 'Extra spaces', value: `  ${answer}  `, shouldPass: true },
        { label: 'Internal spaces normalized', value: answer.replace(/\s+/g, ' '), shouldPass: true },
    ];
    // For numeric answers, test type variations
    if (/^\d+(\.\d+)?$/.test(answer.trim())) {
        const num = answer.trim();
        variants.push({ label: 'As array', value: `[${num}]`, shouldPass: false }); // Should fail
        variants.push({ label: 'As quoted string', value: `"${num}"`, shouldPass: false }); // Should fail
    }
    // For simple numeric strings like "3", "6.0"
    if (/^-?\d+(\.\d+)?$/.test(answer.trim())) {
        const num = Number(answer.trim());
        variants.push({ label: 'With extra decimals (1.00 vs 1)', value: num.toFixed(2), shouldPass: true }); // Might pass with normalization
    }
    return variants;
}
/**
 * Test a single edge case variant
 */
function testVariant(answer, expected, problemType, problemSlug) {
    let result;
    if (problemType === 'fill_blank') {
        result = (0, judge_1.judgeFillBlank)(answer, expected);
    }
    else if (problemType === 'multiple_choice') {
        result = (0, judge_1.judgeMultipleChoice)(answer, expected);
    }
    else if (problemType === 'ordering') {
        try {
            const submitted = JSON.parse(answer);
            const correct = JSON.parse(expected);
            result = (0, judge_1.judgeOrdering)(submitted, correct);
        }
        catch (e) {
            result = {
                status: 'runtime_error',
                output: `JSON parse error: ${e}`,
                runtime_ms: 0,
                results: [],
            };
        }
    }
    else {
        result = {
            status: 'runtime_error',
            output: 'Unsupported problem type',
            runtime_ms: 0,
            results: [],
        };
    }
    return {
        variant: answer,
        result,
        passed: result.status === 'accepted',
    };
}
/**
 * Main test runner
 */
async function runAllTests() {
    console.log('🧪 Starting Comprehensive Judge Test Suite\n');
    try {
        // Fetch all problems with test cases
        const problemsResult = await pool.query(`
      SELECT p.slug, p.problem_type, p.title, p.difficulty, p.category,
             tc.expected_output, p.hints
      FROM problems p
      LEFT JOIN test_cases tc ON tc.problem_id = p.id
      WHERE p.active = true AND p.problem_type IN ('fill_blank', 'multiple_choice', 'ordering')
      ORDER BY p.difficulty, p.category, p.created_at
    `);
        const problems = problemsResult.rows;
        console.log(`📋 Found ${problems.length} test cases across all problems\n`);
        let totalTests = 0;
        let passedTests = 0;
        let failedTests = 0;
        let inconsistencies = [];
        const results = [];
        for (const problem of problems) {
            const { slug, problem_type: problemType, title, difficulty, category, expected_output: expectedOutput, } = problem;
            if (!expectedOutput) {
                console.log(`⏭️  Skipping ${slug} (no expected output)`);
                continue;
            }
            const edgeCases = generateEdgeCases(expectedOutput, problemType);
            const testResults = [];
            for (const edgeCase of edgeCases) {
                const test = testVariant(edgeCase.value, expectedOutput, problemType, slug);
                testResults.push({
                    variant: edgeCase.label,
                    input: edgeCase.value,
                    passed: test.passed,
                    expectedPass: edgeCase.shouldPass,
                    status: test.result.status,
                });
                totalTests++;
                // Check if result matches expectation
                if (test.passed === edgeCase.shouldPass) {
                    passedTests++;
                }
                else {
                    failedTests++;
                    const direction = edgeCase.shouldPass ? 'FAILED' : 'UNEXPECTEDLY PASSED';
                    inconsistencies.push(`${slug}: "${edgeCase.label}" (${edgeCase.value}) ${direction} [expected: ${edgeCase.shouldPass}]`);
                }
            }
            results.push({
                slug,
                type: problemType,
                category,
                difficulty,
                tests: testResults,
            });
        }
        // Print results
        console.log('━'.repeat(80));
        console.log('📊 TEST RESULTS SUMMARY\n');
        console.log(`Total Edge Case Tests: ${totalTests}`);
        console.log(`✅ Passed: ${passedTests}`);
        console.log(`❌ Failed: ${failedTests}`);
        console.log(`Success Rate: ${((passedTests / totalTests) * 100).toFixed(1)}%\n`);
        if (inconsistencies.length > 0) {
            console.log('⚠️  INCONSISTENCIES DETECTED:\n');
            inconsistencies.forEach((inc) => console.log(`  • ${inc}`));
            console.log();
        }
        // Print detailed results by category
        console.log('━'.repeat(80));
        console.log('📋 DETAILED RESULTS BY PROBLEM\n');
        const categories = [...new Set(results.map((r) => r.category))];
        for (const cat of categories.sort()) {
            const catProblems = results.filter((r) => r.category === cat);
            console.log(`\n🏷️  ${cat} (${catProblems.length} problems)`);
            console.log('─'.repeat(80));
            for (const problem of catProblems) {
                const allPassed = problem.tests.every((t) => t.passed === t.expectedPass);
                const icon = allPassed ? '✅' : '❌';
                console.log(`  ${icon} [${problem.difficulty}] ${problem.slug} (${problem.type})`);
                // Show only failed variants
                const failedVariants = problem.tests.filter((t) => t.passed !== t.expectedPass);
                if (failedVariants.length > 0) {
                    failedVariants.forEach((test) => {
                        const expectedStr = test.expectedPass ? 'should pass' : 'should fail';
                        const actualStr = test.passed ? 'passed' : 'failed';
                        console.log(`    ❌ "${test.variant}": ${expectedStr} but ${actualStr}`);
                        console.log(`       Input: "${test.input}" | Status: ${test.status}`);
                    });
                }
                else if (problem.tests.length > 0) {
                    console.log(`      All ${problem.tests.length} edge cases behaved as expected`);
                }
            }
        }
        console.log('\n' + '━'.repeat(80));
        console.log('✨ Test suite complete\n');
    }
    catch (error) {
        console.error('❌ Error running tests:', error);
        process.exit(1);
    }
    finally {
        await pool.end();
    }
}
// Run tests
runAllTests().catch((error) => {
    console.error('Fatal error:', error);
    process.exit(1);
});
