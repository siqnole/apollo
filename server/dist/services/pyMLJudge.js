"use strict";
/**
 * Python ML Code Judge
 * Supports PyTorch, TensorFlow, Matplotlib, NumPy, Pandas, scikit-learn
 * Executes user code in sandboxed Python environment and validates output
 */
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
exports.judgePythonML = judgePythonML;
exports.checkMLDependencies = checkMLDependencies;
exports.getMLLibraryVersions = getMLLibraryVersions;
const child_process_1 = require("child_process");
const util_1 = require("util");
const fs = __importStar(require("fs/promises"));
const path = __importStar(require("path"));
const os = __importStar(require("os"));
const crypto = __importStar(require("crypto"));
const execAsync = (0, util_1.promisify)(child_process_1.exec);
const TIMEOUT_MS = 30000; // 30 seconds for ML training
const MAX_OUTPUT = 50000;
/**
 * Execute Python ML code and validate output
 * Supports: PyTorch, TensorFlow, Matplotlib, NumPy, Pandas, scikit-learn
 */
async function judgePythonML(userCode, expectedOutputPattern, problemSlug) {
    const startTime = Date.now();
    try {
        // Create temporary Python file
        const tmpDir = await fs.mkdtemp(path.join(os.tmpdir(), 'apollo-ml-'));
        const pythonFile = path.join(tmpDir, `${problemSlug}_${crypto.randomBytes(4).toString('hex')}.py`);
        // Write user code to file
        await fs.writeFile(pythonFile, userCode, 'utf-8');
        try {
            // Execute with proper timeout and output capture
            const { stdout, stderr } = await execAsync(`python3 "${pythonFile}"`, {
                timeout: TIMEOUT_MS,
                maxBuffer: MAX_OUTPUT,
                cwd: tmpDir,
                env: {
                    ...process.env,
                    PYTHONUNBUFFERED: '1',
                    PYTHONDONTWRITEBYTECODE: '1',
                },
            });
            const runtime = Date.now() - startTime;
            const output = stdout + stderr;
            // Validate against expected pattern
            if (expectedOutputPattern === 'any' || !expectedOutputPattern) {
                // Just check if code ran without error
                return {
                    status: 'accepted',
                    output,
                    runtime_ms: runtime,
                };
            }
            // Try regex matching
            const regex = new RegExp(expectedOutputPattern, 'is');
            if (regex.test(output)) {
                return {
                    status: 'accepted',
                    output,
                    runtime_ms: runtime,
                };
            }
            // Pattern didn't match
            return {
                status: 'wrong_answer',
                output,
                runtime_ms: runtime,
                error: `Output did not match expected pattern: ${expectedOutputPattern}`,
            };
        }
        catch (err) {
            const runtime = Date.now() - startTime;
            const errorMessage = err.message || String(err);
            const output = err.stdout || '';
            const stderr = err.stderr || '';
            // Distinguish error types
            if (err.code === 'ETIMEDOUT' || runtime > TIMEOUT_MS) {
                return {
                    status: 'timeout',
                    output: `Timeout after ${TIMEOUT_MS}ms\n${output}`,
                    runtime_ms: TIMEOUT_MS,
                    error: 'Execution took too long (likely infinite loop or heavy computation)',
                };
            }
            // Check for syntax errors
            if (stderr.includes('SyntaxError')) {
                return {
                    status: 'syntax_error',
                    output: stderr,
                    runtime_ms: runtime,
                    error: 'Python syntax error detected',
                };
            }
            // Runtime error (ImportError, NameError, etc.)
            return {
                status: 'runtime_error',
                output: `${output}\n${stderr}`,
                runtime_ms: runtime,
                error: errorMessage,
            };
        }
        finally {
            // Cleanup
            try {
                await fs.rm(tmpDir, { recursive: true, force: true });
            }
            catch (cleanupErr) {
                console.error('Error cleaning up temp directory:', cleanupErr);
            }
        }
    }
    catch (err) {
        return {
            status: 'runtime_error',
            output: '',
            runtime_ms: Date.now() - startTime,
            error: `Judge error: ${err.message}`,
        };
    }
}
/**
 * Validate that required libraries are available
 */
async function checkMLDependencies() {
    const libs = ['torch', 'tensorflow', 'matplotlib', 'numpy', 'pandas', 'sklearn'];
    const available = [];
    const missing = [];
    for (const lib of libs) {
        try {
            await execAsync(`python3 -c "import ${lib}"`);
            available.push(lib);
        }
        catch {
            missing.push(lib);
        }
    }
    return { available, missing };
}
/**
 * Get installed library versions
 */
async function getMLLibraryVersions() {
    const versions = {};
    const libs = [
        { name: 'torch', import: 'torch' },
        { name: 'tensorflow', import: 'tensorflow' },
        { name: 'matplotlib', import: 'matplotlib' },
        { name: 'numpy', import: 'numpy' },
        { name: 'pandas', import: 'pandas' },
        { name: 'sklearn', import: 'sklearn' },
    ];
    for (const lib of libs) {
        try {
            const { stdout } = await execAsync(`python3 -c "import ${lib.import}; print(${lib.import}.__version__)"`);
            versions[lib.name] = stdout.trim();
        }
        catch {
            versions[lib.name] = 'not installed';
        }
    }
    return versions;
}
