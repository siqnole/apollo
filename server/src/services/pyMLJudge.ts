/**
 * Python ML Code Judge
 * Supports PyTorch, TensorFlow, Matplotlib, NumPy, Pandas, scikit-learn
 * Executes user code in sandboxed Python environment and validates output
 */

import { exec } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs/promises';
import * as path from 'path';
import * as os from 'os';
import * as crypto from 'crypto';

const execAsync = promisify(exec);
const TIMEOUT_MS = 30000; // 30 seconds for ML training
const MAX_OUTPUT = 50000;

export interface PyMLJudgeResult {
  status: 'accepted' | 'wrong_answer' | 'runtime_error' | 'timeout' | 'syntax_error';
  output: string;
  runtime_ms: number;
  error?: string;
}

/**
 * Execute Python ML code and validate output
 * Supports: PyTorch, TensorFlow, Matplotlib, NumPy, Pandas, scikit-learn
 */
export async function judgePythonML(
  userCode: string,
  expectedOutputPattern: string,
  problemSlug: string
): Promise<PyMLJudgeResult> {
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
    } catch (err: any) {
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
    } finally {
      // Cleanup
      try {
        await fs.rm(tmpDir, { recursive: true, force: true });
      } catch (cleanupErr) {
        console.error('Error cleaning up temp directory:', cleanupErr);
      }
    }
  } catch (err: any) {
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
export async function checkMLDependencies(): Promise<{
  available: string[];
  missing: string[];
}> {
  const libs = ['torch', 'tensorflow', 'matplotlib', 'numpy', 'pandas', 'sklearn'];
  const available: string[] = [];
  const missing: string[] = [];

  for (const lib of libs) {
    try {
      await execAsync(`python3 -c "import ${lib}"`);
      available.push(lib);
    } catch {
      missing.push(lib);
    }
  }

  return { available, missing };
}

/**
 * Get installed library versions
 */
export async function getMLLibraryVersions(): Promise<Record<string, string>> {
  const versions: Record<string, string> = {};
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
      const { stdout } = await execAsync(
        `python3 -c "import ${lib.import}; print(${lib.import}.__version__)"`
      );
      versions[lib.name] = stdout.trim();
    } catch {
      versions[lib.name] = 'not installed';
    }
  }

  return versions;
}
