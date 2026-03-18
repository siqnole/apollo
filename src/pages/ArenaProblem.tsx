import React, { useEffect, useState, useCallback, useRef } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getProblem, submitSolution, runCode, ProblemDetail, SubmissionResult } from '../services/api';
import { downloadProblemPdf } from '../utils/downloadPdf';
import CodeMirror from '@uiw/react-codemirror';
import { javascript } from '@codemirror/lang-javascript';
import { python } from '@codemirror/lang-python';
import { cpp } from '@codemirror/lang-cpp';
import { oneDark } from '@codemirror/theme-one-dark';
import { EditorView } from '@codemirror/view';
import ReactMarkdown from 'react-markdown';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';
import 'katex/dist/katex.min.css';
import ShellTerminal from '../components/arena/ShellTerminal';
import SqlEditor from '../components/arena/SqlEditor';

const BANNED_KEY = 'apollo_banned_slugs';
const PASTE_THRESHOLD = 20; // chars — below this is treated as a quick fix, not cheating

function getBannedSlugs(): Set<string> {
  try {
    const raw = localStorage.getItem(BANNED_KEY);
    return new Set(raw ? JSON.parse(raw) : []);
  } catch { return new Set(); }
}
function addBannedSlug(slug: string) {
  const set = getBannedSlugs();
  set.add(slug);
  localStorage.setItem(BANNED_KEY, JSON.stringify(Array.from(set)));
}

// ── Colours ────────────────────────────────────────────────────────────────
const gold        = '#C9A84C';
const muted       = '#8A7D65';
const dim         = '#4A4236';
const border      = 'rgba(201,168,76,0.18)';
const borderBright= 'rgba(201,168,76,0.4)';
const bg          = '#0A0906';
const bg2         = '#0F0D09';

const DIFF_COLORS: Record<string, string> = {
  Easy: '#2AC87D', Medium: '#C9A84C', Hard: '#E05C2A', Expert: '#C82A2A',
};

const LANGUAGES = [
  { value: 'javascript', label: 'JavaScript' },
  { value: 'typescript', label: 'TypeScript'  },
  { value: 'python',     label: 'Python'       },
  { value: 'cpp',        label: 'C++'          },
  { value: 'c',          label: 'C'            },
  { value: 'csharp',     label: 'C#'           },
];

const STATUS_STYLES: Record<string, { color: string; bg: string; label: string }> = {
  accepted:      { color: '#2AC87D', bg: 'rgba(42,200,125,0.1)',  label: '✓ Accepted'       },
  wrong_answer:  { color: '#E05C2A', bg: 'rgba(224,92,42,0.1)',   label: '✗ Wrong Answer'   },
  runtime_error: { color: '#C82A2A', bg: 'rgba(200,42,42,0.1)',   label: '⚠ Runtime Error'  },
  compile_error: { color: '#C82A2A', bg: 'rgba(200,42,42,0.1)',   label: '⚠ Compile Error'  },
  time_limit:    { color: '#E05C2A', bg: 'rgba(224,92,42,0.1)',   label: '⏱ Time Limit'     },
  running:       { color: '#C9A84C', bg: 'rgba(201,168,76,0.1)', label: '⟳ Running…'       },
};

// ── Markdown + KaTeX renderer ──────────────────────────────────────────────
// Custom components to apply Apollo's dark theme to markdown elements
const markdownComponents: React.ComponentProps<typeof ReactMarkdown>['components'] = {
  p: ({ children, node }) => {
    // Check if this paragraph contains only a code block to avoid nested p > pre
    if (node?.children?.length === 1 && node?.children?.[0]?.type === 'element' && node?.children?.[0]?.tagName === 'pre') {
      return <>{children}</>;
    }
    return (
      <p style={{ margin: '0.75rem 0', lineHeight: 1.75, color: '#D4CCBC', fontWeight: 300 }}>
        {children}
      </p>
    );
  },
  strong: ({ children }) => (
    <strong style={{ color: '#F0E8D6', fontWeight: 600 }}>{children}</strong>
  ),
  em: ({ children }) => (
    <em style={{ color: '#D4CCBC' }}>{children}</em>
  ),
  code: ({ inline, className, children, ...props }: any) => {
    if (inline) {
      return (
        <code 
          className="inline-code"
          style={{
            background: 'rgba(201,168,76,0.08)',
            border: '1px solid rgba(201,168,76,0.15)',
            padding: '0.15em 0.35em',
            margin: '0 0.05em',
            fontFamily: '"DM Mono", monospace',
            fontSize: '0.9em',
            color: '#C9A84C',
            borderRadius: '2px',
            whiteSpace: 'nowrap',
          }}>
          {children}
        </code>
      );
    }
    return (
      <pre 
        className="code-block"
        style={{
          background: '#0A0906',
          border: '1px solid rgba(201,168,76,0.18)',
          padding: '1rem',
          borderRadius: '4px',
          overflowX: 'auto',
          fontFamily: '"DM Mono", monospace',
          fontSize: '0.8rem',
          color: '#F0E8D6',
          margin: '0.75rem 0',
        }}>
        <code className={className} {...props}>{children}</code>
      </pre>
    );
  },
  blockquote: ({ children }) => (
    <blockquote style={{
      borderLeft: '3px solid rgba(201,168,76,0.4)',
      margin: '0.75rem 0',
      padding: '0.5rem 1rem',
      color: '#8A7D65',
    }}>
      {children}
    </blockquote>
  ),
  ul: ({ children }) => (
    <ul style={{ paddingLeft: '1.5rem', margin: '0.5rem 0', color: '#D4CCBC' }}>{children}</ul>
  ),
  ol: ({ children }) => (
    <ol style={{ paddingLeft: '1.5rem', margin: '0.5rem 0', color: '#D4CCBC' }}>{children}</ol>
  ),
  li: ({ children }) => (
    <li style={{ margin: '0.25rem 0', lineHeight: 1.7, fontWeight: 300 }}>{children}</li>
  ),
  h1: ({ children }) => (
    <h1 style={{ fontFamily: 'Cinzel, serif', color: '#F0E8D6', fontSize: '1.2rem', margin: '1.25rem 0 0.5rem' }}>{children}</h1>
  ),
  h2: ({ children }) => (
    <h2 style={{ fontFamily: 'Cinzel, serif', color: '#F0E8D6', fontSize: '1.05rem', margin: '1rem 0 0.5rem' }}>{children}</h2>
  ),
  h3: ({ children }) => (
    <h3 style={{ fontFamily: 'DM Mono, monospace', color: gold, fontSize: '0.85rem', letterSpacing: '0.1em', textTransform: 'uppercase', margin: '1rem 0 0.4rem' }}>{children}</h3>
  ),
  hr: () => (
    <hr style={{ border: 'none', borderTop: '1px solid rgba(201,168,76,0.15)', margin: '1rem 0' }} />
  ),
  table: ({ children }) => (
    <table style={{ borderCollapse: 'collapse', width: '100%', margin: '0.75rem 0', fontSize: '0.85rem' }}>{children}</table>
  ),
  th: ({ children }) => (
    <th style={{ border: '1px solid rgba(201,168,76,0.18)', padding: '0.4rem 0.75rem', color: gold, fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', letterSpacing: '0.1em', textTransform: 'uppercase', background: '#0F0D09' }}>{children}</th>
  ),
  td: ({ children }) => (
    <td style={{ border: '1px solid rgba(201,168,76,0.12)', padding: '0.4rem 0.75rem', color: '#D4CCBC' }}>{children}</td>
  ),
};

// KaTeX inline styles override — force white/gold text on dark background
const katexStyle = `
  .katex { color: #F0E8D6; font-size: 1.05em; }
  .katex-display { margin: 1rem 0; overflow-x: auto; }
  .katex-display > .katex { color: #F0E8D6; }
  /* Inline code styling for grouped codeblocks */
  .inline-code {
    display: inline;
    margin: 0 0.05em;
  }
  /* Group consecutive inline codes without extra spacing */
  .inline-code + .inline-code {
    margin-left: 0;
  }
  /* Code block styling */
  .code-block {
    display: block;
  }
`;

function ProblemDescription({ text }: { text: string }) {
  return (
    <>
      <style>{katexStyle}</style>
      <ReactMarkdown
        remarkPlugins={[remarkMath]}
        rehypePlugins={[rehypeKatex]}
        components={markdownComponents}
      >
        {text}
      </ReactMarkdown>
    </>
  );
}

const HIGH_LEVEL = new Set(['javascript', 'typescript', 'python']);

// ── Default starter templates ──────────────────────────────────────────────
const DEFAULT_TEMPLATES: Record<string, string> = {
  cpp: `#include <iostream>
#include <vector>
#include <sstream>
using namespace std;

int main() {
    int n;
    cin >> n;
    // your solution here
    return 0;
}`,
  c: `#include <stdio.h>
#include <stdlib.h>

int main() {
    int n;
    scanf("%d", &n);
    // your solution here
    return 0;
}`,
  csharp: `using System;

class Solution {
    static void Main(string[] args) {
        // your solution here
    }
}`,
};

function getStarterCode(sc: Record<string, string> | null, language: string): string {
  if (sc?.[language]) return sc[language];
  if (DEFAULT_TEMPLATES[language]) return DEFAULT_TEMPLATES[language];
  if (HIGH_LEVEL.has(language)) return sc?.javascript ?? sc?.typescript ?? sc?.python ?? '';
  return '';
}

function getLangExtension(language: string) {
  switch (language) {
    case 'javascript': return javascript({ jsx: false });
    case 'typescript': return javascript({ typescript: true });
    case 'python':     return python();
    case 'cpp':
    case 'c':
    case 'csharp':     return cpp();
    default:           return javascript();
  }
}

// ── Apollo CodeMirror theme ────────────────────────────────────────────────
const apolloTheme = EditorView.theme({
  '&': { backgroundColor: '#0F0D09', color: '#F0E8D6', height: '100%' },
  '.cm-content': { padding: '1.25rem', fontFamily: '"DM Mono", monospace', fontSize: '0.85rem', lineHeight: '1.6' },
  '.cm-gutters': { backgroundColor: '#0A0906', borderRight: '1px solid rgba(201,168,76,0.12)', color: '#4A4236' },
  '.cm-activeLineGutter': { backgroundColor: 'rgba(201,168,76,0.05)' },
  '.cm-activeLine': { backgroundColor: 'rgba(201,168,76,0.04)' },
  '.cm-cursor': { borderLeftColor: '#C9A84C' },
  '.cm-selectionBackground': { backgroundColor: 'rgba(201,168,76,0.15) !important' },
  '.cm-focused .cm-selectionBackground': { backgroundColor: 'rgba(201,168,76,0.2) !important' },
  '.cm-matchingBracket': { backgroundColor: 'rgba(201,168,76,0.25)', outline: '1px solid rgba(201,168,76,0.4)' },
  '.cm-scroller': { overflow: 'auto' },
}, { dark: true });

// ── Ordering drag component ────────────────────────────────────────────────
function OrderingInput({ options, value, onChange }: {
  options: { id: string; label: string; body: string }[];
  value: string[];
  onChange: (v: string[]) => void;
}) {
  const [dragging, setDragging] = useState<number | null>(null);
  const items = value.length > 0
    ? value.map(v => options.find(o => o.body === v)!).filter(Boolean)
    : [...options];

  const handleDragStart = (i: number) => setDragging(i);
  const handleDrop = (i: number) => {
    if (dragging === null || dragging === i) return;
    const arr = [...items];
    const [moved] = arr.splice(dragging, 1);
    arr.splice(i, 0, moved);
    onChange(arr.map(o => o.body));
    setDragging(null);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
      {items.map((opt, i) => (
        <div
          key={opt.id}
          draggable
          onDragStart={() => handleDragStart(i)}
          onDragOver={e => e.preventDefault()}
          onDrop={() => handleDrop(i)}
          style={{
            padding: '0.85rem 1rem', border: `1px solid ${border}`,
            background: dragging === i ? 'rgba(201,168,76,0.08)' : bg2,
            cursor: 'grab', display: 'flex', alignItems: 'center', gap: '0.75rem',
            transition: 'background 0.15s', userSelect: 'none',
          }}
        >
          <span style={{ color: dim, fontFamily: 'DM Mono, monospace', fontSize: '0.7rem' }}>⠿</span>
          <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.72rem', color: gold, minWidth: '20px' }}>{i + 1}.</span>
          <span style={{ fontSize: '0.9rem', color: '#F0E8D6' }}>{opt.body}</span>
        </div>
      ))}
    </div>
  );
}

// ── AI Detected Banner ────────────────────────────────────────────────────
function AiDetectedBanner({ slug }: { slug: string }) {
  const [appeal, setAppeal]     = useState('');
  const [submitted, setSubmitted] = useState(false);

  const handleAppeal = () => {
    if (!appeal.trim()) return;
    console.warn('[APOLLO ANTI-CHEAT] Appeal received', {
      slug,
      timestamp: new Date().toISOString(),
      reason: appeal.trim(),
    });
    setSubmitted(true);
  };

  return (
    <div style={{
      position: 'fixed', inset: 0, zIndex: 9999,
      background: 'rgba(10,6,6,0.96)',
      display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
      gap: '1.5rem',
    }}>
      {/* Pulsing red glow */}
      <div style={{
        position: 'absolute', inset: 0, pointerEvents: 'none',
        boxShadow: 'inset 0 0 120px rgba(200,42,42,0.35)',
      }} />

      <div style={{
        fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', letterSpacing: '0.3em',
        textTransform: 'uppercase', color: 'rgba(200,42,42,0.7)',
      }}>
        Apollo Anti-Cheat
      </div>

      <div style={{
        fontFamily: 'Cinzel, serif', fontSize: 'clamp(2rem, 6vw, 3.5rem)',
        fontWeight: 900, color: '#C82A2A', letterSpacing: '0.08em',
        textShadow: '0 0 40px rgba(200,42,42,0.6)',
        textAlign: 'center',
      }}>
        AI DETECTED
      </div>

      <div style={{
        fontFamily: 'DM Sans, sans-serif', fontSize: '0.95rem', fontWeight: 300,
        color: '#8A7D65', textAlign: 'center', maxWidth: '480px', lineHeight: 1.7,
      }}>
        A large paste was detected in your editor. This problem has been permanently locked for your account.
      </div>

      <div style={{
        width: '1px', height: '40px', background: 'rgba(200,42,42,0.3)',
      }} />

      {submitted ? (
        <div style={{
          fontFamily: 'DM Mono, monospace', fontSize: '0.75rem',
          color: '#2AC87D', letterSpacing: '0.1em',
        }}>
          Appeal submitted. A developer will review your case.
        </div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem', width: '100%', maxWidth: '440px' }}>
          <div style={{
            fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em',
            textTransform: 'uppercase', color: '#4A4236',
          }}>
            Think this is a mistake?
          </div>
          <textarea
            value={appeal}
            onChange={e => setAppeal(e.target.value)}
            placeholder="Explain what happened…"
            rows={3}
            style={{
              background: '#0F0D09', border: '1px solid rgba(200,42,42,0.3)',
              color: '#F0E8D6', padding: '0.75rem 1rem',
              fontFamily: 'DM Sans, sans-serif', fontSize: '0.88rem',
              outline: 'none', resize: 'vertical', lineHeight: 1.6,
              width: '100%', boxSizing: 'border-box',
            }}
          />
          <button
            onClick={handleAppeal}
            disabled={!appeal.trim()}
            style={{
              background: 'transparent', border: '1px solid rgba(200,42,42,0.5)',
              color: appeal.trim() ? '#C82A2A' : '#4A4236',
              fontFamily: 'DM Mono, monospace', fontSize: '0.7rem',
              letterSpacing: '0.1em', textTransform: 'uppercase',
              padding: '0.65rem 1.5rem', cursor: appeal.trim() ? 'pointer' : 'not-allowed',
              transition: 'all 0.15s', alignSelf: 'flex-start',
            }}
          >
            Submit Appeal
          </button>
        </div>
      )}
    </div>
  );
}

// ── Main page ──────────────────────────────────────────────────────────────
export default function ArenaProblem() {
  const { slug }   = useParams<{ slug: string }>();
  const navigate   = useNavigate();

  const [problem,    setProblem]    = useState<ProblemDetail | null>(null);
  const [loading,    setLoading]    = useState(true);
  const [language,   setLanguage]   = useState('javascript');
  const [code,       setCode]       = useState('');
  const [fnName,     setFnName]     = useState<string | null>(null);
  const [answer,     setAnswer]     = useState('');
  const [ordering,   setOrdering]   = useState<string[]>([]);
  const [result,     setResult]     = useState<SubmissionResult | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [activeTab,     setActiveTab]     = useState<'problem' | 'hints' | 'submissions'>('problem');
  const [shellXp,       setShellXp]       = useState<number | null>(null);
  const [revealedHints, setRevealedHints] = useState(0);
  const [hintXpPenalty, setHintXpPenalty] = useState(0);
  const [banned,        setBanned]        = useState(() => slug ? getBannedSlugs().has(slug) : false);
  const [downloading,   setDownloading]   = useState(false);
  const [debugMode,     setDebugMode]     = useState(false);
  const problemPanelRef = useRef<HTMLDivElement>(null);

  const handleDownload = useCallback(async () => {
    if (!problem || !problemPanelRef.current) return;
    setDownloading(true);
    try {
      await downloadProblemPdf({
        element:    problemPanelRef.current,
        filename:   `${problem.slug}.pdf`,
        title:      problem.title,
        difficulty: problem.difficulty,
        category:   problem.category,
        xpReward:   problem.xp_reward,
      });
    } finally {
      setDownloading(false);
    }
  }, [problem]);

  const triggerBan = useCallback(() => {
    if (!slug) return;
    addBannedSlug(slug);
    setBanned(true);
    console.warn('[APOLLO ANTI-CHEAT] Large paste detected', { slug, timestamp: new Date().toISOString() });
  }, [slug]);

  // CodeMirror extension: block paste/drop above threshold
  const pasteBlockExtension = useCallback(() => EditorView.domEventHandlers({
    paste(event) {
      const text = event.clipboardData?.getData('text') ?? '';
      if (text.length > PASTE_THRESHOLD) {
        event.preventDefault();
        triggerBan();
      }
      // small pastes (quick fixes) pass through
    },
    drop(event) {
      const text = event.dataTransfer?.getData('text') ?? '';
      if (text.length > PASTE_THRESHOLD) {
        event.preventDefault();
        triggerBan();
      }
    },
  }), [triggerBan]);

  useEffect(() => {
    if (!slug) return;
    getProblem(slug)
      .then(p => {
        setProblem(p);
        const supported = p.supported_languages ?? [];
        const preferred = ['javascript', 'typescript', 'python', 'cpp', 'c', 'csharp'];
        const initLang = preferred.find(l => supported.includes(l)) ?? supported[0] ?? 'javascript';
        setLanguage(initLang);
        const initialCode = getStarterCode(p.starter_code, initLang);
        setCode(initialCode);
        const match = initialCode.match(/function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/) ??
                      initialCode.match(/(?:const|let|var)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=/) ??
                      initialCode.match(/^def\s+([a-zA-Z][a-zA-Z0-9_]*)\s*\(/m);
        setFnName(match?.[1] ?? null);
      })
      .catch(() => navigate('/arena'))
      .finally(() => setLoading(false));
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [slug, navigate]);

  useEffect(() => {
    if (!problem) return;
    const newCode = getStarterCode(problem.starter_code, language);
    setCode(newCode);
    const match = newCode.match(/function\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/) ??
                  newCode.match(/^def\s+([a-zA-Z][a-zA-Z0-9_]*)\s*\(/m) ??
                  newCode.match(/(?:const|let|var)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*=/) ??
                  newCode.match(/(?:public\s+static\s+\w+|auto)\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\(/);
    setFnName(match?.[1] ?? null);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [language, problem]);

  const handleSubmit = useCallback(async (mode: 'run' | 'submit') => {
    if (!problem || submitting) return;
    setSubmitting(true);
    setResult(null);
    try {
      const isCodeLocal = problem.problem_type === 'code' || problem.problem_type === 'debug';
      const isHtmlLocal = problem.problem_type === 'html_css';
      const isSqlLocal  = problem.problem_type === 'sql';

      // Paid hints start from the 2nd hint onwards; first is always free
      const paidHintsUsed = Math.max(0, revealedHints - 1);

      if (mode === 'run' && isCodeLocal) {
        // Use the /api/run endpoint for debugging
        const runResult = await runCode({
          language:    language,
          code:        code,
          fn_name:     fnName ?? undefined,
          debug_mode:  debugMode,
        });
        setResult({
          id: '',
          status: runResult.error ? 'runtime_error' : 'accepted',
          output: runResult.output || runResult.error || 'No output',
          runtime_ms: runResult.runtime_ms,
          test_results: [],
          xp_awarded: 0,
        } as SubmissionResult);
      } else {
        // Use the submission endpoint for actual judging
        const payload: any = { problem_slug: problem.slug };

        if (paidHintsUsed > 0) payload.hints_used = paidHintsUsed;

        if (isCodeLocal) {
          payload.language = language;
          payload.code     = code;
          payload.fn_name  = fnName;
        } else if (isHtmlLocal || isSqlLocal) {
          payload.code = code;
        } else if (problem.problem_type === 'ordering') {
          payload.answer = JSON.stringify(ordering.length ? ordering : problem.options.map(o => o.body));
        } else {
          payload.answer = answer;
        }

        const res = await submitSolution(payload);
        setResult(res);
      }
    } catch (e: any) {
      setResult({ id: '', status: 'runtime_error', output: e?.response?.data?.error ?? 'Submission failed', runtime_ms: 0, test_results: [], xp_awarded: 0 });
    } finally {
      setSubmitting(false);
    }
  }, [problem, language, code, answer, ordering, submitting, fnName, debugMode]);

  if (loading || !problem) return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: bg }}>
      <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.75rem', color: dim, letterSpacing: '0.2em', textTransform: 'uppercase' as const }}>Loading challenge…</div>
    </div>
  );

  const isCode  = problem.problem_type === 'code' || problem.problem_type === 'debug';
  const isHtml  = problem.problem_type === 'html_css';
  const isShell = problem.problem_type === 'shell' || problem.problem_type === 'shell_sql';
  const isSql   = problem.problem_type === 'sql';
  const resultStyle = result ? (STATUS_STYLES[result.status] ?? STATUS_STYLES.runtime_error) : null;
  const visibleTests = problem.test_cases.filter(tc => !tc.is_hidden);

  return (
    <div style={{ height: '100vh', display: 'flex', flexDirection: 'column', background: bg, color: '#F0E8D6', overflow: 'hidden' }}>

      {/* ── AI Detection Banner (renders on top of everything) ── */}
      {banned && slug && <AiDetectedBanner slug={slug} />}

      {/* ── Top bar ── */}
      <div style={{ height: '48px', flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 1.5rem', borderBottom: `1px solid ${border}`, background: 'rgba(10,9,6,0.95)', zIndex: 10 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '1.25rem' }}>
          <a href="/arena" style={{ fontFamily: 'Cinzel, serif', fontSize: '0.9rem', fontWeight: 700, color: gold, textDecoration: 'none', letterSpacing: '0.08em' }}>APOLLO</a>
          <span style={{ color: dim }}>›</span>
          <span style={{ fontFamily: 'DM Sans, sans-serif', fontSize: '0.85rem', color: muted }}>{problem.title}</span>
          <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', color: DIFF_COLORS[problem.difficulty], border: `1px solid ${DIFF_COLORS[problem.difficulty]}44`, padding: '0.15rem 0.5rem' }}>{problem.difficulty}</span>
          <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', color: dim, border: `1px solid ${border}`, padding: '0.15rem 0.5rem' }}>+{problem.xp_reward} XP</span>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          {/* PDF download */}
          <button
            onClick={handleDownload}
            disabled={downloading}
            title="Download as PDF"
            style={{
              fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', letterSpacing: '0.08em',
              textTransform: 'uppercase' as const, background: 'transparent',
              border: `1px solid ${border}`, color: downloading ? dim : muted,
              padding: '0.35rem 0.75rem', cursor: downloading ? 'not-allowed' : 'pointer',
              opacity: downloading ? 0.5 : 1, transition: 'color 0.15s, border-color 0.15s',
              display: 'flex', alignItems: 'center', gap: '0.4rem',
            }}
            onMouseEnter={e => { if (!downloading) { e.currentTarget.style.color = gold; e.currentTarget.style.borderColor = borderBright; }}}
            onMouseLeave={e => { e.currentTarget.style.color = muted; e.currentTarget.style.borderColor = border; }}
          >
            {downloading ? '⟳' : '↓'} PDF
          </button>
          {isCode && (
            <select
              value={language}
              onChange={e => setLanguage(e.target.value)}
              style={{ background: bg2, border: `1px solid ${border}`, color: muted, padding: '0.3rem 0.6rem', fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', outline: 'none', cursor: 'pointer' }}
            >
              {LANGUAGES.filter(l =>
                !problem.supported_languages?.length ||
                problem.supported_languages.includes('any') ||
                problem.supported_languages.includes(l.value)
              ).map(l => <option key={l.value} value={l.value}>{l.label}</option>)}
            </select>
          )}
          {(isCode || isSql) && (
            <>
              <button
                onClick={() => handleSubmit('run')}
                disabled={submitting || banned}
                style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', letterSpacing: '0.08em', textTransform: 'uppercase' as const, background: 'transparent', border: `1px solid ${borderBright}`, color: gold, padding: '0.35rem 1rem', cursor: (submitting || banned) ? 'not-allowed' : 'pointer', opacity: (submitting || banned) ? 0.6 : 1 }}
              >
                Run
              </button>
              {isCode && (
                <button
                  onClick={() => setDebugMode(!debugMode)}
                  title={debugMode ? 'Debug mode: ON - showing detailed output' : 'Debug mode: OFF - minimal output'}
                  style={{
                    fontFamily: 'DM Mono, monospace',
                    fontSize: '0.7rem',
                    letterSpacing: '0.08em',
                    textTransform: 'uppercase' as const,
                    background: debugMode ? 'rgba(201,168,76,0.15)' : 'transparent',
                    border: `1px solid ${debugMode ? gold : border}`,
                    color: debugMode ? gold : muted,
                    padding: '0.35rem 0.75rem',
                    cursor: 'pointer',
                    transition: 'all 0.15s',
                  }}
                  onMouseEnter={e => {
                    e.currentTarget.style.borderColor = gold;
                    e.currentTarget.style.color = gold;
                    if (!debugMode) e.currentTarget.style.background = 'rgba(201,168,76,0.08)';
                  }}
                  onMouseLeave={e => {
                    e.currentTarget.style.borderColor = debugMode ? gold : border;
                    e.currentTarget.style.color = debugMode ? gold : muted;
                    e.currentTarget.style.background = debugMode ? 'rgba(201,168,76,0.15)' : 'transparent';
                  }}
                >
                  🐛 Debug
                </button>
              )}
            </>
          )}
          {!isShell && (
            <button
              onClick={() => handleSubmit('submit')}
              disabled={submitting || banned}
              style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', letterSpacing: '0.08em', textTransform: 'uppercase' as const, background: (submitting || banned) ? dim : gold, color: bg, border: 'none', padding: '0.35rem 1.25rem', cursor: (submitting || banned) ? 'not-allowed' : 'pointer', fontWeight: 500 }}
            >
              {submitting ? 'Judging…' : isCode ? 'Submit' : isHtml ? 'Check HTML' : isSql ? 'Run Query' : 'Check Answer'}
            </button>
          )}
          {isShell && shellXp !== null && (
            <span style={{ fontFamily: 'Cinzel, serif', fontSize: '0.8rem', color: '#2AC87D' }}>✓ Solved +{shellXp} XP</span>
          )}
        </div>
      </div>

      {/* ── Main split layout ── */}
      <div style={{ flex: 1, display: 'flex', overflow: 'hidden' }}>

        {/* ── Left panel: Problem ── */}
        <div style={{ width: '45%', borderRight: `1px solid ${border}`, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
          <div style={{ display: 'flex', borderBottom: `1px solid ${border}`, flexShrink: 0 }}>
            {([
              ['problem', 'Problem'],
              ['hints', hintXpPenalty > 0 ? `Hints (−${hintXpPenalty} XP)` : `Hints (${problem.hints?.length ?? 0})`],
              ['submissions', 'My Submissions'],
            ] as [string, string][]).map(([id, label]) => (
              <button key={id} onClick={() => setActiveTab(id as any)} style={{ padding: '0.6rem 1.25rem', background: 'none', border: 'none', borderBottom: activeTab === id ? `2px solid ${gold}` : '2px solid transparent', color: activeTab === id ? gold : dim, fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', letterSpacing: '0.1em', textTransform: 'uppercase' as const, cursor: 'pointer', marginBottom: '-1px' }}>
                {label}
              </button>
            ))}
          </div>

          <div ref={problemPanelRef} style={{ flex: 1, overflowY: 'auto', padding: '1.5rem' }}>

            {activeTab === 'problem' && (
              <>
                <h2 style={{ fontFamily: 'Cinzel, serif', fontSize: '1.25rem', fontWeight: 700, marginBottom: '1.25rem', marginTop: 0 }}>{problem.title}</h2>

                {/* ── Markdown + LaTeX description ── */}
                <ProblemDescription text={problem.description} />

                {/* Examples from visible test cases */}
                {visibleTests.length > 0 && (problem.problem_type === 'code' || problem.problem_type === 'debug') && (
                  <div style={{ marginTop: '1.5rem' }}>
                    <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: dim, marginBottom: '0.75rem' }}>Examples</div>
                    {visibleTests.map((tc, i) => (
                      <div key={tc.id} style={{ background: bg2, border: `1px solid ${border}`, padding: '0.85rem 1rem', marginBottom: '0.5rem' }}>
                        <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: dim, marginBottom: '0.4rem' }}>Example {i + 1}</div>
                        <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.78rem', color: muted, whiteSpace: 'pre-wrap' }}>
                          <span style={{ color: dim }}>Input: </span>{tc.input.replace(/\\n/g, '\n') || '(none)'}
                        </div>
                        {tc.expected_output && (
                          <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.78rem', color: muted, marginTop: '0.25rem', whiteSpace: 'pre-wrap' }}>
                            <span style={{ color: dim }}>Output: </span>{tc.expected_output.replace(/\\n/g, '\n')}
                          </div>
                        )}
                        {tc.explanation && <div style={{ fontSize: '0.8rem', color: dim, marginTop: '0.4rem' }}>{tc.explanation}</div>}
                      </div>
                    ))}
                  </div>
                )}
              </>
            )}

            {activeTab === 'hints' && (() => {
              const hints = problem.hints || [];
              const nextIndex = revealedHints; // 0-based index of the next hint to reveal
              const isFree = revealedHints === 0;

              const revealNext = () => {
                const cost = isFree ? 0 : 10;
                setRevealedHints(n => n + 1);
                setHintXpPenalty(p => p + cost);
              };

              return (
                <div>
                  {/* Header */}
                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.25rem' }}>
                    <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: dim }}>
                      Hints
                    </div>
                    {hintXpPenalty > 0 && (
                      <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: '#E05C2A', letterSpacing: '0.05em' }}>
                        −{hintXpPenalty} XP deducted
                      </div>
                    )}
                  </div>

                  {hints.length === 0 ? (
                    <div style={{ color: dim, fontSize: '0.85rem' }}>No hints for this problem.</div>
                  ) : (
                    <>
                      {/* Revealed hints */}
                      {hints.slice(0, revealedHints).map((h, i) => (
                        <div key={i} style={{ background: bg2, border: `1px solid ${border}`, padding: '0.85rem 1rem', marginBottom: '0.5rem', display: 'flex', gap: '0.75rem', alignItems: 'flex-start' }}>
                          <span style={{ color: gold, fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', flexShrink: 0, marginTop: '0.1rem' }}>#{i + 1}</span>
                          <span style={{ fontSize: '0.88rem', color: muted, fontWeight: 300, lineHeight: 1.6 }}>{h}</span>
                        </div>
                      ))}

                      {/* Locked hints */}
                      {hints.slice(revealedHints).map((_, i) => (
                        <div key={revealedHints + i} style={{ background: bg2, border: `1px solid ${border}`, padding: '0.85rem 1rem', marginBottom: '0.5rem', display: 'flex', gap: '0.75rem', alignItems: 'center', opacity: 0.35 }}>
                          <span style={{ color: dim, fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', flexShrink: 0 }}>#{revealedHints + i + 1}</span>
                          <span style={{ fontSize: '0.82rem', color: dim, fontFamily: 'DM Mono, monospace', letterSpacing: '0.15em' }}>{'▒'.repeat(18)}</span>
                        </div>
                      ))}

                      {/* Reveal button */}
                      {nextIndex < hints.length && (
                        <button
                          onClick={revealNext}
                          style={{
                            marginTop: '0.75rem',
                            width: '100%',
                            padding: '0.75rem 1rem',
                            background: 'transparent',
                            border: `1px solid ${isFree ? 'rgba(42,200,125,0.4)' : borderBright}`,
                            color: isFree ? '#2AC87D' : gold,
                            fontFamily: 'DM Mono, monospace',
                            fontSize: '0.7rem',
                            letterSpacing: '0.1em',
                            textTransform: 'uppercase' as const,
                            cursor: 'pointer',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            gap: '0.6rem',
                            transition: 'background 0.15s',
                          }}
                          onMouseEnter={e => (e.currentTarget.style.background = isFree ? 'rgba(42,200,125,0.06)' : 'rgba(201,168,76,0.06)')}
                          onMouseLeave={e => (e.currentTarget.style.background = 'transparent')}
                        >
                          <span>{isFree ? '✦' : '⚠'}</span>
                          <span>
                            Reveal hint #{nextIndex + 1}
                            {isFree
                              ? ' — free'
                              : ' — costs 10 XP'}
                          </span>
                        </button>
                      )}

                      {nextIndex >= hints.length && revealedHints > 0 && (
                        <div style={{ marginTop: '0.75rem', fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: dim, textAlign: 'center' as const, letterSpacing: '0.1em' }}>
                          All hints revealed
                        </div>
                      )}
                    </>
                  )}
                </div>
              );
            })()}

            {activeTab === 'submissions' && (
              <div style={{ color: muted, fontSize: '0.85rem', fontWeight: 300 }}>
                Submission history coming soon.
              </div>
            )}
          </div>
        </div>

        {/* ── Right panel: Editor / Answer ── */}
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>

          {(isCode || problem.problem_type === 'html_css') && (
            <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' as const }}>
              {problem.problem_type === 'html_css' ? (
                <div style={{ flex: 1, display: 'flex', overflow: 'hidden' }}>
                  <div style={{ width: '50%', borderRight: `1px solid ${border}`, overflow: 'hidden' }}>
                    <div style={{ padding: '0.4rem 1rem', borderBottom: `1px solid ${border}`, fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.15em', textTransform: 'uppercase' as const, color: dim, background: bg }}>
                      HTML / CSS
                    </div>
                    <CodeMirror
                      value={code}
                      height="100%"
                      theme={[oneDark, apolloTheme]}
                      extensions={[javascript({ jsx: false }), EditorView.lineWrapping, pasteBlockExtension()]}
                      onChange={(val) => setCode(val)}
                      basicSetup={{ lineNumbers: true, highlightActiveLine: true, bracketMatching: true, indentOnInput: true, tabSize: 2, foldGutter: false }}
                      style={{ height: 'calc(100% - 32px)', fontSize: '0.82rem' }}
                    />
                  </div>
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column' as const, overflow: 'hidden' }}>
                    <div style={{ padding: '0.4rem 1rem', borderBottom: `1px solid ${border}`, fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.15em', textTransform: 'uppercase' as const, color: dim, background: bg, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                      <span>Preview</span>
                      <span style={{ color: '#2AC87D', fontSize: '0.55rem' }}>● live</span>
                    </div>
                    <iframe srcDoc={code} sandbox="allow-scripts" style={{ flex: 1, border: 'none', background: '#fff' }} title="HTML Preview" />
                  </div>
                </div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column' as const, height: '100%' }}>
                  <div style={{ padding: '0.4rem 1rem', borderBottom: `1px solid ${border}`, fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.15em', textTransform: 'uppercase' as const, color: dim, background: bg, flexShrink: 0 }}>
                    {LANGUAGES.find(l => l.value === language)?.label ?? language}
                    {fnName && <span style={{ marginLeft: '0.75rem', color: gold, letterSpacing: '0.05em' }}>fn: {fnName}</span>}
                  </div>
                  <CodeMirror
                    value={code}
                    height="100%"
                    theme={[oneDark, apolloTheme]}
                    extensions={[getLangExtension(language), EditorView.lineWrapping, pasteBlockExtension()]}
                    onChange={(val) => setCode(val)}
                    basicSetup={{ lineNumbers: true, highlightActiveLine: true, bracketMatching: true, autocompletion: true, indentOnInput: true, tabSize: 2, foldGutter: false }}
                    style={{ flex: 1, fontSize: '0.85rem', overflow: 'hidden' }}
                  />
                </div>
              )}
            </div>
          )}

          {isSql && (
            <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' as const }}>
              <SqlEditor value={code} onChange={setCode} />
            </div>
          )}

          {isShell && (
            <div style={{ flex: 1, overflow: 'hidden', display: 'flex', flexDirection: 'column' as const }}>
              <ShellTerminal problemSlug={problem.slug} onSolved={(xp) => setShellXp(xp)} />
            </div>
          )}

          {problem.problem_type === 'multiple_choice' && (
            <div style={{ flex: 1, overflowY: 'auto', padding: '1.5rem' }}>
              <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: dim, marginBottom: '1.25rem' }}>Select one answer</div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.6rem' }}>
                {problem.options.map(opt => (
                  <button key={opt.id} onClick={() => setAnswer(opt.label)} style={{
                    display: 'flex', alignItems: 'center', gap: '1rem', padding: '1rem 1.25rem',
                    background: answer === opt.label ? 'rgba(201,168,76,0.08)' : bg2,
                    border: `1px solid ${answer === opt.label ? gold : border}`,
                    cursor: 'pointer', textAlign: 'left' as const, transition: 'all 0.15s',
                    ...(result && answer === opt.label ? { borderColor: result.status === 'accepted' ? '#2AC87D' : '#E05C2A', background: result.status === 'accepted' ? 'rgba(42,200,125,0.08)' : 'rgba(224,92,42,0.08)' } : {}),
                  }}>
                    <span style={{ fontFamily: 'Cinzel, serif', fontSize: '1rem', fontWeight: 700, color: answer === opt.label ? gold : dim, minWidth: '24px' }}>{opt.label}</span>
                    <span style={{ fontSize: '0.9rem', color: '#F0E8D6', fontWeight: 300 }}>{opt.body}</span>
                  </button>
                ))}
              </div>
            </div>
          )}

          {problem.problem_type === 'fill_blank' && (
            <div style={{ flex: 1, overflowY: 'auto', padding: '1.5rem' }}>
              <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: dim, marginBottom: '1.25rem' }}>Type your answer</div>
              <textarea
                value={answer}
                onChange={e => setAnswer(e.target.value)}
                onKeyDown={e => {
                  // Submit on Enter only when Shift is not held and there's no newline needed
                  if (e.key === 'Enter' && !e.shiftKey && !answer.includes('\n')) {
                    e.preventDefault();
                    handleSubmit('submit');
                  }
                }}
                onPaste={e => {
                  const text = e.clipboardData.getData('text');
                  if (text.length > PASTE_THRESHOLD) { e.preventDefault(); triggerBan(); }
                }}
                onDrop={e => {
                  const text = e.dataTransfer.getData('text');
                  if (text.length > PASTE_THRESHOLD) { e.preventDefault(); triggerBan(); }
                }}
                placeholder={"Enter your answer…\n(use multiple lines for matrix output)"}
                rows={3}
                style={{ width: '100%', background: bg2, border: `1px solid ${border}`, color: '#F0E8D6', padding: '0.85rem 1rem', fontFamily: 'DM Mono, monospace', fontSize: '1rem', outline: 'none', boxSizing: 'border-box' as const, letterSpacing: '0.05em', resize: 'vertical', lineHeight: 1.7 }}
              />
              <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', color: dim, marginTop: '0.4rem', letterSpacing: '0.05em' }}>
                Press Enter to submit · Shift+Enter for new line
              </div>
            </div>
          )}

          {problem.problem_type === 'short_answer' && (
            <div style={{ flex: 1, overflowY: 'auto', padding: '1.5rem' }}>
              <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: dim, marginBottom: '1.25rem' }}>Write your answer</div>
              <textarea
                value={answer}
                onChange={e => setAnswer(e.target.value)}
                onPaste={e => {
                  const text = e.clipboardData.getData('text');
                  if (text.length > PASTE_THRESHOLD) { e.preventDefault(); triggerBan(); }
                }}
                onDrop={e => {
                  const text = e.dataTransfer.getData('text');
                  if (text.length > PASTE_THRESHOLD) { e.preventDefault(); triggerBan(); }
                }}
                placeholder="Write your answer here…"
                style={{ width: '100%', minHeight: '200px', background: bg2, border: `1px solid ${border}`, color: '#F0E8D6', padding: '0.85rem 1rem', fontFamily: 'DM Sans, sans-serif', fontSize: '0.9rem', outline: 'none', boxSizing: 'border-box' as const, resize: 'vertical', lineHeight: 1.7 }}
              />
            </div>
          )}

          {problem.problem_type === 'ordering' && (
            <div style={{ flex: 1, overflowY: 'auto', padding: '1.5rem' }}>
              <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: dim, marginBottom: '1.25rem' }}>Drag to reorder</div>
              <OrderingInput options={problem.options} value={ordering} onChange={setOrdering} />
            </div>
          )}

          {/* ── Result / Output panel ── */}
          {!isShell && (
            <div style={{ height: '220px', borderTop: `1px solid ${border}`, background: bg2, display: 'flex', flexDirection: 'column', flexShrink: 0 }}>
              <div style={{ padding: '0.5rem 1rem', borderBottom: `1px solid ${border}`, display: 'flex', alignItems: 'center', gap: '1rem', flexShrink: 0 }}>
                <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.15em', textTransform: 'uppercase' as const, color: dim }}>Output</span>
                {result && resultStyle && (
                  <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', color: resultStyle.color, background: resultStyle.bg, padding: '0.2rem 0.6rem', letterSpacing: '0.05em' }}>
                    {resultStyle.label}
                  </span>
                )}
                {result?.xp_awarded ? (
                  <span style={{ fontFamily: 'Cinzel, serif', fontSize: '0.8rem', color: gold }}>+{result.xp_awarded} XP</span>
                ) : null}
                {result?.runtime_ms ? (
                  <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: dim }}>{result.runtime_ms}ms</span>
                ) : null}
              </div>
              <div style={{ flex: 1, overflowY: 'auto', padding: '0.85rem 1rem' }}>
                {submitting && (
                  <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.75rem', color: gold, letterSpacing: '0.1em' }}>Running test cases…</div>
                )}
                {!submitting && !result && (
                  <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.72rem', color: dim }}>Run or submit to see output.</div>
                )}
                {result && (
                  <>
                    {/* Show stdout/stderr separately for run mode */}
                    {!result.test_results || result.test_results.length === 0 ? (
                      <>
                        {/* Standard output */}
                        {result.output && (
                          <div style={{ marginBottom: '0.5rem' }}>
                            <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: gold, letterSpacing: '0.05em', marginBottom: '0.25rem' }}>STDOUT:</div>
                            <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.78rem', color: muted, whiteSpace: 'pre-wrap' as const, background: 'rgba(0,0,0,0.3)', padding: '0.5rem', borderRadius: '2px', border: `1px solid rgba(201,168,76,0.1)` }}>{result.output}</div>
                          </div>
                        )}
                        {/* Standard error */}
                        {(result as any).stderr && (
                          <div>
                            <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: '#E05C2A', letterSpacing: '0.05em', marginBottom: '0.25rem' }}>STDERR:</div>
                            <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.78rem', color: '#FF6B6B', whiteSpace: 'pre-wrap' as const, background: 'rgba(224,92,42,0.1)', padding: '0.5rem', borderRadius: '2px', border: `1px solid rgba(224,92,42,0.2)` }}>{(result as any).stderr}</div>
                          </div>
                        )}
                      </>
                    ) : (
                      <>
                        <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.78rem', color: muted, whiteSpace: 'pre-wrap' as const, marginBottom: '0.75rem' }}>{result.output}</div>
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.4rem' }}>
                          {result.test_results.map((tr, i) => (
                            <div key={i} style={{ display: 'flex', alignItems: 'flex-start', gap: '0.75rem', padding: '0.4rem 0.6rem', background: tr.passed ? 'rgba(42,200,125,0.05)' : 'rgba(224,92,42,0.05)', border: `1px solid ${tr.passed ? 'rgba(42,200,125,0.15)' : 'rgba(224,92,42,0.15)'}` }}>
                              <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: tr.passed ? '#2AC87D' : '#E05C2A', flexShrink: 0 }}>{tr.passed ? '✓' : '✗'}</span>
                              <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: tr.passed ? muted : dim }}>
                                {tr.input}{!tr.passed && tr.error ? ` — ${tr.error}` : ''}
                              </span>
                            </div>
                          ))}
                        </div>
                      </>
                    )}
                  </>
                )}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}