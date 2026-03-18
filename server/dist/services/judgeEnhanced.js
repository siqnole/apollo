"use strict";
/**
 * Enhanced Judge with Flexible Type Handling
 * Accepts numeric answers in various formats:
 * - 17, "17", [17], 17.0, "17.0" all normalize to the same value
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.judgeFillBlankEnhanced = judgeFillBlankEnhanced;
exports.extractValue = extractValue;
exports.valuesMatch = valuesMatch;
/**
 * Extract meaningful value from various input formats
 * Handles: 17, "17", [17], 17.0, etc.
 */
function extractValue(s) {
    const trimmed = s.trim();
    // Try JSON parsing first
    try {
        const parsed = JSON.parse(trimmed);
        // If it's a single-element array with a number, extract it
        if (Array.isArray(parsed) && parsed.length === 1 && typeof parsed[0] === 'number') {
            return { type: 'number', value: parsed[0] };
        }
        // If it's an object, return it as-is
        if (typeof parsed === 'object' && parsed !== null) {
            return { type: 'object', value: parsed };
        }
        // If it's a number (JSON can parse bare numbers)
        if (typeof parsed === 'number') {
            return { type: 'number', value: parsed };
        }
        // If it's a string value (e.g., "hello")
        if (typeof parsed === 'string') {
            return { type: 'string', value: parsed.toLowerCase().trim() };
        }
    }
    catch {
        // Not valid JSON, continue
    }
    // Try parsing as number
    if (/^-?\d+(\.\d+)?$/.test(trimmed)) {
        return { type: 'number', value: Number(trimmed) };
    }
    // Default to string normalization
    return {
        type: 'string',
        value: trimmed.toLowerCase().replace(/\s+/g, ' '),
    };
}
/**
 * Compare two values with flexible type coercion
 * Note: Type boundaries are preserved - "17" (JSON string) ≠ 17 (number)
 *       But 17 ≈ [17] (array extraction) and 17 ≈ 17.0 (decimal precision)
 */
function valuesMatch(actual, expected) {
    // Number comparison (handles 17 ≈ 17.0)
    if (actual.type === 'number' && expected.type === 'number') {
        return Math.abs(actual.value - expected.value) < 1e-9;
    }
    // String comparison (case-insensitive, whitespace-normalized)
    if (actual.type === 'string' && expected.type === 'string') {
        return actual.value === expected.value;
    }
    // Cross-type: Number ≈ Array (if array has single number)
    // This handles: 17 matches [17]
    if (actual.type === 'number' && expected.type === 'array') {
        if (expected.value.length === 1 && typeof expected.value[0] === 'number') {
            return Math.abs(actual.value - expected.value[0]) < 1e-9;
        }
    }
    if (actual.type === 'array' && expected.type === 'number') {
        if (actual.value.length === 1 && typeof actual.value[0] === 'number') {
            return Math.abs(actual.value[0] - expected.value) < 1e-9;
        }
    }
    // NO cross-type comparison between Number and String types
    // Reason: "17" (JSON string) is semantically different from 17 (number)
    // They should be rejected as mismatches
    // Array/object comparison: must be exact same structure
    if (actual.type === 'array' && expected.type === 'array') {
        return JSON.stringify(actual.value) === JSON.stringify(expected.value);
    }
    if (actual.type === 'object' && expected.type === 'object') {
        return JSON.stringify(actual.value) === JSON.stringify(expected.value);
    }
    return false;
}
/**
 * Judge fill-blank answers with flexible type handling
 */
function judgeFillBlankEnhanced(answer, expected) {
    try {
        const actualValue = extractValue(answer);
        const expectedValue = extractValue(expected);
        const passed = valuesMatch(actualValue, expectedValue);
        return {
            status: passed ? 'accepted' : 'wrong_answer',
            output: passed ? 'Correct!' : 'Incorrect. Try again.',
            runtime_ms: 0,
            results: [
                {
                    input: '',
                    expected,
                    actual: answer,
                    passed,
                },
            ],
        };
    }
    catch (err) {
        return {
            status: 'runtime_error',
            output: `Error evaluating answer: ${err}`,
            runtime_ms: 0,
            results: [],
        };
    }
}
