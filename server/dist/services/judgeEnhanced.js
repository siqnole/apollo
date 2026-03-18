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
 */
function valuesMatch(actual, expected) {
    // Number comparison
    if (actual.type === 'number' && expected.type === 'number') {
        // Allow small floating point differences
        return Math.abs(actual.value - expected.value) < 1e-9;
    }
    // String comparison
    if (actual.type === 'string' && expected.type === 'string') {
        return actual.value === expected.value;
    }
    // Cross-type numeric comparison: 17 matches "17" or [17]
    if ((actual.type === 'number' || actual.type === 'string') &&
        (expected.type === 'number' || expected.type === 'string')) {
        const aNum = actual.type === 'number'
            ? actual.value
            : !isNaN(Number(actual.value))
                ? Number(actual.value)
                : null;
        const eNum = expected.type === 'number'
            ? expected.value
            : !isNaN(Number(expected.value))
                ? Number(expected.value)
                : null;
        if (aNum !== null && eNum !== null) {
            return Math.abs(aNum - eNum) < 1e-9;
        }
        // Fall back to string comparison
        return actual.type === 'string' && expected.type === 'string' && actual.value === expected.value;
    }
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
