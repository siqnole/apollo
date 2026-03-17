import React, { useState, useEffect, useRef, useCallback } from 'react';
import api from '../../services/api';

interface Props {
  problemSlug: string;
  onSolved: (xpAwarded: number) => void;
}

interface HistoryEntry {
  type: 'input' | 'output' | 'error' | 'system';
  text: string;
}

const gold   = '#C9A84C';
const dim    = '#4A4236';
const muted  = '#8A7D65';
const border = 'rgba(201,168,76,0.18)';
const bg     = '#0A0906';
const bg2    = '#0F0D09';

const SESSION_MS = 30 * 60 * 1000;

function formatTime(ms: number): string {
  if (ms <= 0) return '00:00';
  const totalSec = Math.floor(ms / 1000);
  const m = Math.floor(totalSec / 60).toString().padStart(2, '0');
  const s = (totalSec % 60).toString().padStart(2, '0');
  return `${m}:${s}`;
}

export default function ShellTerminal({ problemSlug, onSolved }: Props) {
  const [sessionId,   setSessionId]   = useState<string | null>(null);
  const [cwd,         setCwd]         = useState('/home/user');
  const [history,     setHistory]     = useState<HistoryEntry[]>([]);
  const [input,       setInput]       = useState('');
  const [loading,     setLoading]     = useState(true);
  const [checking,    setChecking]    = useState(false);
  const [cmdHistory,  setCmdHistory]  = useState<string[]>([]);
  const [historyIdx,  setHistoryIdx]  = useState(-1);
  const [expiresAt,   setExpiresAt]   = useState<number | null>(null);
  const [timeLeft,    setTimeLeft]    = useState<number>(SESSION_MS);
  const [resetting,   setResetting]   = useState(false);

  const inputRef    = useRef<HTMLInputElement>(null);
  const bottomRef   = useRef<HTMLDivElement>(null);
  const sessionRef  = useRef<string | null>(null);

  // ── Start sandbox session ─────────────────────────────────────────────
  useEffect(() => {
    let mounted = true;
    setLoading(true);
    setHistory([{ type: 'system', text: 'Starting sandbox…' }]);

    api.post('/api/sandbox/start', { problem_slug: problemSlug })
      .then(({ data }) => {
        if (!mounted) return;
        setSessionId(data.session_id);
        sessionRef.current = data.session_id;
        setExpiresAt(data.expires_at);
        setTimeLeft(data.expires_at - Date.now());
        setHistory([
          { type: 'system', text: '┌─ Apollo Shell Sandbox ──────────────────────────────' },
          { type: 'system', text: '│  Linux (Ubuntu 22.04) — type commands below'         },
          { type: 'system', text: '│  Run "check" when you think you\'ve solved it'        },
          { type: 'system', text: '└────────────────────────────────────────────────────' },
          { type: 'system', text: '' },
        ]);
        setLoading(false);
      })
      .catch(() => {
        if (!mounted) return;
        setHistory([{ type: 'error', text: 'Failed to start sandbox. Is the server running?' }]);
        setLoading(false);
      });

    return () => {
      mounted = false;
      if (sessionRef.current) api.delete(`/api/sandbox/${sessionRef.current}`).catch(() => {});
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [problemSlug]);

  // ── Countdown ticker ──────────────────────────────────────────────────
  useEffect(() => {
    if (!expiresAt) return;
    const tick = setInterval(() => {
      const remaining = expiresAt - Date.now();
      setTimeLeft(remaining);
      if (remaining <= 0) {
        clearInterval(tick);
        setHistory(h => [...h, { type: 'error', text: '⏱ Session expired. Refresh to start a new sandbox.' }]);
        setSessionId(null);
        sessionRef.current = null;
      }
    }, 1000);
    return () => clearInterval(tick);
  }, [expiresAt]);

  // ── Auto-scroll ───────────────────────────────────────────────────────
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [history]);

  const push = (entries: HistoryEntry[]) =>
    setHistory(h => [...h, ...entries]);

  // ── Reset timer ───────────────────────────────────────────────────────
  const resetTimer = useCallback(async () => {
    if (!sessionId || resetting) return;
    setResetting(true);
    try {
      const { data } = await api.post('/api/sandbox/reset-timer', { session_id: sessionId });
      setExpiresAt(data.expires_at);
      setTimeLeft(data.expires_at - Date.now());
      push([{ type: 'system', text: '⏱ Timer reset to 30:00' }]);
    } catch {
      push([{ type: 'error', text: 'Failed to reset timer.' }]);
    } finally {
      setResetting(false);
    }
  }, [sessionId, resetting]);

  // ── Submit command ────────────────────────────────────────────────────
  const runCommand = useCallback(async (cmd: string) => {
    const trimmed = cmd.trim();
    if (!trimmed || !sessionId) return;

    push([{ type: 'input', text: `${cwd} $ ${trimmed}` }]);
    setCmdHistory(h => [trimmed, ...h.slice(0, 99)]);
    setHistoryIdx(-1);
    setInput('');

    if (trimmed === 'clear') { setHistory([]); return; }

    if (trimmed === 'check') {
      setChecking(true);
      try {
        const { data } = await api.post('/api/sandbox/check', {
          session_id:   sessionId,
          problem_slug: problemSlug,
        });
        push([{
          type: data.passed ? 'system' : 'error',
          text: data.passed
            ? `✓ ${data.message}${data.xp_awarded ? ` (+${data.xp_awarded} XP)` : ''}`
            : `✗ ${data.message}`,
        }]);
        if (data.passed) onSolved(data.xp_awarded ?? 0);
      } catch {
        push([{ type: 'error', text: 'Check failed — server error.' }]);
      } finally {
        setChecking(false);
      }
      return;
    }

    try {
      const { data } = await api.post('/api/sandbox/exec', {
        session_id: sessionId,
        command:    trimmed,
        cwd,
      });

      const entries: HistoryEntry[] = [];
      if (data.stdout) entries.push({ type: 'output', text: data.stdout.trimEnd() });
      if (data.stderr) entries.push({ type: 'error',  text: data.stderr.trimEnd() });
      push(entries);
      if (data.cwd) setCwd(data.cwd);
    } catch {
      push([{ type: 'error', text: 'Command failed — server error.' }]);
    }
  }, [sessionId, cwd, problemSlug, onSolved]);

  // ── Keyboard handling ─────────────────────────────────────────────────
  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      runCommand(input);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      const idx = Math.min(historyIdx + 1, cmdHistory.length - 1);
      setHistoryIdx(idx);
      setInput(cmdHistory[idx] ?? '');
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      const idx = Math.max(historyIdx - 1, -1);
      setHistoryIdx(idx);
      setInput(idx === -1 ? '' : cmdHistory[idx] ?? '');
    } else if (e.key === 'Tab') {
      e.preventDefault();
    }
  };

  const entryColor = (type: HistoryEntry['type']) => {
    switch (type) {
      case 'input':  return gold;
      case 'output': return '#F0E8D6';
      case 'error':  return '#E05C2A';
      case 'system': return muted;
    }
  };

  const shortCwd = cwd.replace('/home/user', '~');

  // Timer colour: gold normally, red when under 5 minutes
  const timerColor = timeLeft < 5 * 60 * 1000 ? '#E05C2A' : muted;

  return (
    <div
      style={{ height: '100%', display: 'flex', flexDirection: 'column', background: bg, fontFamily: 'DM Mono, monospace', fontSize: '0.82rem' }}
      onClick={() => inputRef.current?.focus()}
    >
      {/* Timer bar */}
      {!loading && (
        <div style={{
          display: 'flex', alignItems: 'center', justifyContent: 'flex-end',
          gap: '0.75rem', padding: '0.3rem 1.25rem',
          borderBottom: `1px solid ${border}`, background: bg2, flexShrink: 0,
        }}>
          <span style={{ color: timerColor, fontSize: '0.72rem', letterSpacing: '0.08em' }}>
            ⏱ {formatTime(timeLeft)}
          </span>
          <button
            onClick={e => { e.stopPropagation(); resetTimer(); }}
            disabled={!sessionId || resetting}
            style={{
              background: 'transparent', border: `1px solid ${border}`,
              color: muted, fontFamily: 'DM Mono, monospace', fontSize: '0.65rem',
              letterSpacing: '0.1em', textTransform: 'uppercase', padding: '0.15rem 0.5rem',
              cursor: 'pointer', borderRadius: '2px', opacity: resetting ? 0.5 : 1,
            }}
          >
            {resetting ? 'resetting…' : 'reset timer'}
          </button>
        </div>
      )}

      {/* Terminal output */}
      <div style={{ flex: 1, overflowY: 'auto', padding: '1rem 1.25rem', lineHeight: 1.7 }}>
        {history.map((entry, i) => (
          <div key={i} style={{ color: entryColor(entry.type), whiteSpace: 'pre-wrap', wordBreak: 'break-all' }}>
            {entry.text}
          </div>
        ))}
        <div ref={bottomRef} />
      </div>

      {/* Input line */}
      <div style={{ borderTop: `1px solid ${border}`, padding: '0.6rem 1.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem', background: bg2, flexShrink: 0 }}>
        {loading || checking ? (
          <span style={{ color: dim, letterSpacing: '0.1em' }}>
            {loading ? 'starting…' : 'checking…'}
          </span>
        ) : (
          <>
            <span style={{ color: muted, flexShrink: 0 }}>{shortCwd}</span>
            <span style={{ color: dim, flexShrink: 0 }}>$</span>
            <input
              ref={inputRef}
              value={input}
              onChange={e => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              disabled={!sessionId || loading || checking}
              autoFocus
              autoComplete="off"
              autoCorrect="off"
              spellCheck={false}
              style={{
                flex: 1, background: 'transparent', border: 'none', outline: 'none',
                color: gold, fontFamily: 'DM Mono, monospace', fontSize: '0.82rem',
                caretColor: gold,
              }}
            />
          </>
        )}
      </div>
    </div>
  );
}