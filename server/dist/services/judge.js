"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.extractFunctionName = extractFunctionName;
exports.judgeCode = judgeCode;
exports.runCodeRaw = runCodeRaw;
exports.judgeMultipleChoice = judgeMultipleChoice;
exports.judgeFillBlank = judgeFillBlank;
exports.judgeOrdering = judgeOrdering;
const child_process_1 = require("child_process");
const util_1 = require("util");
const fs = __importStar(require("fs/promises"));
const path = __importStar(require("path"));
const os = __importStar(require("os"));
const crypto = __importStar(require("crypto"));
const execAsync = (0, util_1.promisify)(child_process_1.exec);
const TIMEOUT_MS = 5000;
const MAX_OUTPUT = 10000;
// ── Normalise output ───────────────────────────────────────────────────────
function normalise(s) {
    return s.trim().replace(/\s+/g, ' ').toLowerCase();
}
/**
 * Smart comparison that handles numeric types specially
 */
function outputsMatch(actual, expected) {
    const actualTrimmed = actual.trim();
    const expectedTrimmed = expected.trim();
    // Try numeric comparison first if both look like numbers
    const actualNum = parseFloat(actualTrimmed);
    const expectedNum = parseFloat(expectedTrimmed);
    if (!isNaN(actualNum) && !isNaN(expectedNum)) {
        // Both are valid numbers - compare numerically with small tolerance
        return Math.abs(actualNum - expectedNum) < 1e-9;
    }
    // Fall back to string normalization for non-numeric answers
    const a = normalise(actualTrimmed);
    const e = normalise(expectedTrimmed);
    if (a === e)
        return true;
    // Try JSON parsing as fallback
    try {
        const pa = JSON.parse(actualTrimmed);
        const pe = JSON.parse(expectedTrimmed);
        return JSON.stringify(pa) === JSON.stringify(pe);
    }
    catch { /* ignore */ }
    return false;
}
// ── Detect input type ──────────────────────────────────────────────────────
// Returns true if a line looks like space-separated numbers (e.g. "5 3 1 4 2")
// and NOT a JSON array or object.
function isSpaceSeparatedNumbers(line) {
    const t = line.trim();
    if (t.startsWith('[') || t.startsWith('{') || t.startsWith('"'))
        return false;
    return /^-?\d+(\.\d+)?(\s+-?\d+(\.\d+)?)*$/.test(t);
}
// Parse a line into the best JS representation for use as a function argument.
// Space-separated numbers → array of numbers.
// Valid JSON → JSON value.
// Anything else → string.
function parseInputLine(line) {
    const t = line.trim();
    if (isSpaceSeparatedNumbers(t)) {
        // Convert "5 3 1 4" → [5, 3, 1, 4]
        const nums = t.split(/\s+/).map(Number);
        return JSON.stringify(nums);
    }
    try {
        JSON.parse(t);
        return t; // valid JSON, use as-is
    }
    catch {
        return JSON.stringify(t); // plain string
    }
}
// Same for Python — returns a Python literal string.
function parseInputLinePy(line) {
    const t = line.trim();
    if (isSpaceSeparatedNumbers(t)) {
        const nums = t.split(/\s+/).map(Number);
        // If only one number, return it as-is (not a list)
        if (nums.length === 1) {
            return String(nums[0]);
        }
        // Multiple numbers: return as list
        return `[${nums.join(', ')}]`;
    }
    try {
        JSON.parse(t);
        return t; // valid JSON literal — also valid Python for arrays/objects/primitives
    }
    catch {
        return JSON.stringify(t); // wrap in quotes as a Python string
    }
}
// ── Extract function name from starter code ────────────────────────────────
function extractFunctionName(code, language) {
    if (language === 'python') {
        const m = code.match(/^def\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/m);
        return m?.[1] ?? null;
    }
    const patterns = [
        /function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/,
        /(?:const|let|var)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=\s*(?:async\s*)?\(/,
        /([a-zA-Z_][a-zA-Z0-9_]*)\s*\([^)]*\)\s*:\s*\w/,
        /(?:public|private|static)?\s+\w+\s+([A-Z][a-zA-Z0-9_]*)\s*\(/,
    ];
    for (const p of patterns) {
        const m = code.match(p);
        if (m?.[1])
            return m[1];
    }
    return null;
}
// ── C/C++ harness builder ──────────────────────────────────────────────────
// If the code has no main(), wrap it with one that reads stdin, calls the
// function, and prints the result space-separated.
function hasMain(code) {
    // Match `int main(` or `int main (` outside of comments/strings (good enough)
    return /\bint\s+main\s*\(/.test(code);
}
function buildCppHarness(code, language) {
    if (hasMain(code))
        return code;
    // Try to extract the first function name and its return type
    // Matches e.g.: vector<int> bubbleSort(  or  int myFunc(
    const fnMatch = code.match(/^[\w:<>*\s]+\s+(\w+)\s*\(/m);
    const fnName = fnMatch?.[1] ?? null;
    if (!fnName)
        return code; // can't auto-wrap, return as-is
    if (language === 'cpp') {
        const needsIostream = !code.includes('<iostream>');
        const prefix = needsIostream ? '#include <iostream>\n' : '';
        return `${prefix}${code}

int main() {
    std::vector<int> arr;
    int x;
    while (std::cin >> x) arr.push_back(x);

    auto result = ${fnName}(arr);

    for (int i = 0; i < (int)result.size(); i++) {
        if (i) std::cout << " ";
        std::cout << result[i];
    }
    std::cout << "\\n";
    return 0;
}
`;
    }
    else {
        // C — simpler, fixed-size array
        return `${code}

int main() {
    int arr[100000];
    int n = 0;
    while (scanf("%d", &arr[n]) == 1) n++;

    ${fnName}(arr, n);

    for (int i = 0; i < n; i++) {
        if (i) printf(" ");
        printf("%d", arr[i]);
    }
    printf("\\n");
    return 0;
}
`;
    }
}
// ── JS/TS harness builder ──────────────────────────────────────────────────
function buildJsHarness(code, input, fnName, debugMode) {
    const lines = input.trim().split('\n');
    const parsedArgs = lines.map(parseInputLine).join(', ');
    const callExpr = fnName
        ? `${fnName}(${parsedArgs})`
        : `(() => {
        const __m = ${JSON.stringify(code)}.match(/(?:function\\s+|(?:const|let|var)\\s+)([a-zA-Z_][a-zA-Z0-9_]*)\\s*[=(]/);
        const __name = __m && __m[1];
        if (!__name || typeof eval(__name) !== 'function') throw new Error('No function found. Make sure your function is declared at the top level.');
        return eval(__name)(${parsedArgs});
      })()`;
    const debugInjection = debugMode ? injectDebugUtilsJs(code) : code;
    return `
${debugInjection}

// ── Apollo harness ───────────────────────────────────────────────────────
try {
  const __result = ${callExpr};
  // If result is an array of numbers, print space-separated for consistency
  if (Array.isArray(__result) && __result.every(x => typeof x === 'number')) {
    console.log(__result.join(' '));
  } else {
    console.log(JSON.stringify(__result));
  }
  ${debugMode ? 'if (typeof DEBUG !== "undefined") DEBUG.flushDebug();' : ''}
} catch(e) { 
  ${debugMode ? 'if (typeof DEBUG !== "undefined") DEBUG.flushDebug();' : ''}
  process.stderr.write(String(e.message || e)); 
  process.exit(1); 
}
`;
}
// ── Python harness builder ─────────────────────────────────────────────────
function buildPyHarness(code, input, fnName, debugMode) {
    const lines = input.trim().split('\n');
    const parsedArgs = lines.map(parseInputLinePy).join(', ');
    const callExpr = fnName
        ? `${fnName}(${parsedArgs})`
        : `list(filter(lambda f: callable(f) and isinstance(f, types.FunctionType), [globals().get(n) for n in globals()]))[0](${parsedArgs})`;
    const debugInjection = debugMode ? injectDebugUtilsPy(code) : code;
    return `
import json, sys, types

${debugInjection}

if __name__ == '__main__':
    try:
        result = ${callExpr}
        # Always use JSON for output to preserve types (strings vs numbers)
        print(json.dumps(result))
        ${debugMode ? 'DEBUG.flush_debug()' : ''}
    except Exception as e:
        ${debugMode ? 'DEBUG.flush_debug()' : ''}
        sys.stderr.write(str(e))
        sys.exit(1)
`;
}
// ── Detect trivial Python solutions ────────────────────────────────────────
// For problems like "sort an array", reject solutions that only use sorted()
// Counts actual algorithm logic by looking for loops, comparisons, or assignments
function isPythonTrivialSort(code) {
    // Split code to only analyze function body (skip docstrings and comments)
    const lines = code.split('\n');
    let inFuncBody = false;
    let bodyLines = [];
    for (const line of lines) {
        const trimmed = line.trim();
        // Skip empty lines and comments
        if (!trimmed || trimmed.startsWith('#'))
            continue;
        if (trimmed.startsWith('def ')) {
            inFuncBody = true;
            continue;
        }
        // Only capture lines inside the function
        if (inFuncBody && trimmed && !trimmed.match(/^"""|^'''/) && !trimmed.match(/^\s*return\s+/)) {
            // Remove inline comments
            const cleanLine = trimmed.split('#')[0];
            if (cleanLine.trim())
                bodyLines.push(cleanLine);
        }
    }
    const bodyCode = bodyLines.join('\n');
    // Check if solution ONLY calls sorted() without any other logic
    // A real sorting algorithm needs: loops (for/while), conditionals, or swaps
    const hasLoop = /\b(for|while)\b/.test(bodyCode);
    const hasConditional = /\b(if|elif|else)\b/.test(bodyCode);
    const hasSwap = /\[.*\]\s*=\s*\[.*\]/.test(bodyCode); // tuple/list unpacking for swaps
    const hasSorted = /\bsorted\s*\(/.test(bodyCode);
    // If they're calling sorted() but have NO loop, conditional, or swap logic, it's trivial
    // Allow solutions that use sorted() IF they also have algorithm logic
    return hasSorted && !hasLoop && !hasConditional && !hasSwap;
}
// ── Judge code ─────────────────────────────────────────────────────────────
async function judgeCode(code, language, testCases, fnName) {
    // Reject trivial Python solutions that only use sorted()
    if (language === 'python' && isPythonTrivialSort(code)) {
        return {
            status: 'wrong_answer',
            output: 'This solution uses only built-in sort functions. Please implement a sorting algorithm yourself to learn.',
            runtime_ms: 0,
            results: [],
        };
    }
    const id = crypto.randomUUID();
    const dir = path.join(os.tmpdir(), `apollo_${id}`);
    await fs.mkdir(dir, { recursive: true });
    const results = [];
    let totalMs = 0;
    try {
        for (const tc of testCases) {
            const start = Date.now();
            let actual = '';
            let error = '';
            try {
                if (language === 'javascript' || language === 'typescript') {
                    const ext = language === 'typescript' ? 'ts' : 'js';
                    const src = path.join(dir, `sol_${crypto.randomUUID().slice(0, 8)}.${ext}`);
                    const harnessed = buildJsHarness(code, tc.input, fnName ?? null);
                    await fs.writeFile(src, harnessed, 'utf8');
                    const runner = language === 'typescript' ? 'npx tsx' : 'node';
                    const { stdout, stderr } = await execAsync(`${runner} "${src}"`, { timeout: TIMEOUT_MS, maxBuffer: MAX_OUTPUT });
                    actual = stdout.trim();
                    error = stderr.trim();
                }
                else if (language === 'python') {
                    const src = path.join(dir, `sol_${crypto.randomUUID().slice(0, 8)}.py`);
                    await fs.writeFile(src, buildPyHarness(code, tc.input, fnName ?? null), 'utf8');
                    const { stdout, stderr } = await execAsync(`python3 "${src}"`, { timeout: TIMEOUT_MS, maxBuffer: MAX_OUTPUT });
                    actual = stdout.trim();
                    error = stderr.trim();
                }
                else if (language === 'cpp' || language === 'c') {
                    const ext = language === 'c' ? 'c' : 'cpp';
                    const src = path.join(dir, `sol_${crypto.randomUUID().slice(0, 8)}.${ext}`);
                    const bin = path.join(dir, `sol_bin`);
                    const harnessed = buildCppHarness(code, language);
                    await fs.writeFile(src, harnessed, 'utf8');
                    const compiler = language === 'c' ? 'gcc' : 'g++ -std=c++17';
                    try {
                        await execAsync(`${compiler} -O2 -o "${bin}" "${src}" -lm`, { timeout: 15000 });
                    }
                    catch (compileErr) {
                        return {
                            status: 'compile_error',
                            output: (compileErr.stderr || compileErr.message || 'Compile failed').slice(0, 2000),
                            runtime_ms: 0,
                            results: [],
                        };
                    }
                    const { stdout, stderr } = await execAsync(`echo ${JSON.stringify(tc.input)} | "${bin}"`, { timeout: TIMEOUT_MS, maxBuffer: MAX_OUTPUT });
                    actual = stdout.trim();
                    error = stderr.trim();
                }
                else if (language === 'csharp') {
                    const src = path.join(dir, `sol_${crypto.randomUUID().slice(0, 8)}.cs`);
                    await fs.writeFile(src, code, 'utf8');
                    let compiled = false;
                    let compileErr = '';
                    try {
                        await execAsync(`mcs -out:"${dir}/sol.exe" "${src}"`, { timeout: 15000 });
                        compiled = true;
                    }
                    catch (e) {
                        const msg = (e.stderr || e.message || '');
                        if (msg.includes('not found') || msg.includes('No such')) {
                            compileErr = 'C# requires Mono. Install with: sudo apt install mono-mcs';
                        }
                        else {
                            compileErr = msg.slice(0, 2000);
                        }
                    }
                    if (!compiled) {
                        return { status: 'compile_error', output: compileErr, runtime_ms: 0, results: [] };
                    }
                    const { stdout, stderr } = await execAsync(`echo ${JSON.stringify(tc.input)} | mono "${dir}/sol.exe"`, { timeout: TIMEOUT_MS, maxBuffer: MAX_OUTPUT });
                    actual = stdout.trim();
                    error = stderr.trim();
                }
                else {
                    return { status: 'runtime_error', output: `Unsupported language: ${language}`, runtime_ms: 0, results: [] };
                }
            }
            catch (e) {
                const isTimeout = e.killed || (e.message || '').includes('timeout');
                const errMsg = (e.stderr || e.message || 'Runtime error').slice(0, 500);
                results.push({
                    input: tc.input, expected: tc.expected_output, actual: '',
                    passed: false, error: isTimeout ? 'Time limit exceeded (5s)' : errMsg,
                });
                if (isTimeout)
                    return { status: 'time_limit', output: 'Time limit exceeded', runtime_ms: TIMEOUT_MS, results };
                continue;
            }
            totalMs += Date.now() - start;
            const passed = outputsMatch(actual, tc.expected_output);
            results.push({ input: tc.input, expected: tc.expected_output, actual, passed, error: error || undefined });
        }
        const allPassed = results.every(r => r.passed);
        const firstFail = results.find(r => !r.passed);
        const hasRuntime = results.some(r => r.error && !r.passed);
        return {
            status: allPassed ? 'accepted' : hasRuntime && !firstFail?.actual ? 'runtime_error' : 'wrong_answer',
            output: allPassed ? 'All test cases passed!' : firstFail?.error || `Expected: ${firstFail?.expected}\nGot: ${firstFail?.actual}`,
            expected: firstFail?.expected,
            runtime_ms: totalMs,
            results,
        };
    }
    finally {
        fs.rm(dir, { recursive: true, force: true }).catch(() => { });
    }
}
// ── Debug utilities injection ──────────────────────────────────────────────
function injectDebugUtilsJs(code) {
    return `
// ── Apollo Debug Utilities ───────────────────────────────────────────
const __DEBUG__ = {
  logs: [],
  vars: {},
  inspect(name, value) {
    const typeStr = Array.isArray(value) ? 'Array' : typeof value === 'object' ? 'Object' : typeof value;
    const preview = typeof value === 'object' ? JSON.stringify(value).slice(0, 50) : String(value);
    this.logs.push(\`📍 \${name}: \${typeStr} = \${preview}\`);
    return value;
  },
  log(...args) {
    this.logs.push(args.map(a => typeof a === 'object' ? JSON.stringify(a) : String(a)).join(' '));
  },
  flushDebug() {
    if (this.logs.length > 0) {
      console.log('\\n━━━ DEBUG OUTPUT ━━━');
      this.logs.forEach(l => console.log(l));
    }
  }
};
const DEBUG = __DEBUG__;

${code}
`;
}
function injectDebugUtilsPy(code) {
    return `
# ── Apollo Debug Utilities ──────────────────────────────────────────
class __DEBUG__:
    logs = []
    def inspect(self, name, value):
        type_str = type(value).__name__
        preview = str(value)[:50]
        self.logs.append(f'📍 {name}: {type_str} = {preview}')
        return value
    def log(self, *args):
        self.logs.append(' '.join(str(a) for a in args))
    def flush_debug(self):
        if self.logs:
            print('\\n━━━ DEBUG OUTPUT ━━━')
            for l in self.logs:
                print(l)

DEBUG = __DEBUG__()

${code}
`;
}
async function runCodeRaw(code, language, input = '', fnName, debugMode = false) {
    const id = crypto.randomUUID();
    const dir = path.join(os.tmpdir(), `apollo_${id}`);
    await fs.mkdir(dir, { recursive: true });
    const start = Date.now();
    try {
        let output = '';
        let error = '';
        if (language === 'javascript' || language === 'typescript') {
            const ext = language === 'typescript' ? 'ts' : 'js';
            const src = path.join(dir, `sol_${crypto.randomUUID().slice(0, 8)}.${ext}`);
            const harnessed = buildJsHarness(code, input, fnName ?? null, debugMode);
            await fs.writeFile(src, harnessed, 'utf8');
            const runner = language === 'typescript' ? 'npx tsx' : 'node';
            try {
                const { stdout, stderr } = await execAsync(`${runner} "${src}"`, { timeout: TIMEOUT_MS, maxBuffer: MAX_OUTPUT });
                output = stdout.trim();
                error = stderr.trim();
            }
            catch (e) {
                error = (e.stderr || e.message || 'Runtime error').slice(0, 2000);
            }
        }
        else if (language === 'python') {
            const src = path.join(dir, `sol_${crypto.randomUUID().slice(0, 8)}.py`);
            await fs.writeFile(src, buildPyHarness(code, input, fnName ?? null, debugMode), 'utf8');
            try {
                const { stdout, stderr } = await execAsync(`python3 "${src}"`, { timeout: TIMEOUT_MS, maxBuffer: MAX_OUTPUT });
                output = stdout.trim();
                error = stderr.trim();
            }
            catch (e) {
                error = (e.stderr || e.message || 'Runtime error').slice(0, 2000);
            }
        }
        else if (language === 'cpp' || language === 'c') {
            const ext = language === 'c' ? 'c' : 'cpp';
            const src = path.join(dir, `sol_${crypto.randomUUID().slice(0, 8)}.${ext}`);
            const bin = path.join(dir, `sol_bin`);
            const harnessed = buildCppHarness(code, language);
            await fs.writeFile(src, harnessed, 'utf8');
            const compiler = language === 'c' ? 'gcc' : 'g++ -std=c++17';
            try {
                await execAsync(`${compiler} -O2 -o "${bin}" "${src}" -lm`, { timeout: 15000 });
                const { stdout, stderr } = await execAsync(`echo ${JSON.stringify(input)} | "${bin}"`, { timeout: TIMEOUT_MS, maxBuffer: MAX_OUTPUT });
                output = stdout.trim();
                error = stderr.trim();
            }
            catch (e) {
                error = (e.stderr || e.message || 'Compile or runtime error').slice(0, 2000);
            }
        }
        else {
            error = `Unsupported language: ${language}`;
        }
        const runtime_ms = Date.now() - start;
        return { output, runtime_ms, error: error || undefined, stderr: error || undefined };
    }
    catch (e) {
        const runtime_ms = Date.now() - start;
        return { output: '', runtime_ms, error: e.message || 'Internal error', stderr: e.message || 'Internal error' };
    }
    finally {
        fs.rm(dir, { recursive: true, force: true }).catch(() => { });
    }
}
// ── Non-code judges ────────────────────────────────────────────────────────
function judgeMultipleChoice(answer, correctLabel) {
    const passed = normalise(answer) === normalise(correctLabel);
    return {
        status: passed ? 'accepted' : 'wrong_answer',
        output: passed ? 'Correct!' : 'Incorrect. Try again.',
        runtime_ms: 0,
        results: [{ input: '', expected: correctLabel, actual: answer, passed }],
    };
}
function judgeFillBlank(answer, expected) {
    const passed = outputsMatch(answer, expected);
    return {
        status: passed ? 'accepted' : 'wrong_answer',
        output: passed ? 'Correct!' : 'Incorrect. Try again.',
        runtime_ms: 0,
        results: [{ input: '', expected, actual: answer, passed }],
    };
}
function judgeOrdering(submitted, correct) {
    const passed = submitted.length === correct.length &&
        submitted.every((v, i) => normalise(v) === normalise(correct[i]));
    return {
        status: passed ? 'accepted' : 'wrong_answer',
        output: passed ? 'Correct order!' : 'Incorrect order.',
        runtime_ms: 0,
        results: [{ input: JSON.stringify(submitted), expected: JSON.stringify(correct), actual: JSON.stringify(submitted), passed }],
    };
}
