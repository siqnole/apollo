import React, { useEffect, useState, useCallback } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import {
  getAdminAppeals,
  updateAppealStatus,
  getAdminSubmissions,
  Appeal,
  AdminSubmission,
} from '../services/api';

// ── Colours (Apollo palette) ───────────────────────────────────────────────
const gold        = '#C9A84C';
const muted       = '#8A7D65';
const dim         = '#4A4236';
const border      = 'rgba(201,168,76,0.18)';
const borderBright= 'rgba(201,168,76,0.4)';
const bg          = '#0A0906';
const bg2         = '#0F0D09';
const red         = '#C82A2A';
const green       = '#2AC87D';

const APPEAL_STATUS_COLORS: Record<string, string> = {
  pending: '#C9A84C',
  cleared: '#2AC87D',
  upheld:  '#C82A2A',
};

const SUBMISSION_STATUS_COLORS: Record<string, { color: string; label: string }> = {
  accepted:      { color: '#2AC87D', label: '✓ Accepted'      },
  wrong_answer:  { color: '#E05C2A', label: '✗ Wrong Answer'  },
  runtime_error: { color: '#C82A2A', label: '⚠ Runtime Error' },
  compile_error: { color: '#C82A2A', label: '⚠ Compile Error' },
  time_limit:    { color: '#E05C2A', label: '⏱ Time Limit'    },
};

const mono: React.CSSProperties = { fontFamily: 'DM Mono, monospace' };
const serif: React.CSSProperties = { fontFamily: 'Cinzel, serif' };
const sans: React.CSSProperties = { fontFamily: 'DM Sans, sans-serif' };

function Badge({ color, children }: { color: string; children: React.ReactNode }) {
  return (
    <span style={{
      ...mono, fontSize: '0.6rem', letterSpacing: '0.08em', textTransform: 'uppercase',
      color, border: `1px solid ${color}44`, padding: '0.15rem 0.5rem',
      background: `${color}11`,
    }}>
      {children}
    </span>
  );
}

function Label({ children }: { children: React.ReactNode }) {
  return (
    <div style={{ ...mono, fontSize: '0.58rem', letterSpacing: '0.2em', textTransform: 'uppercase', color: dim, marginBottom: '0.4rem' }}>
      {children}
    </div>
  );
}

// ── Appeals tab ────────────────────────────────────────────────────────────
function AppealsTab() {
  const [appeals,     setAppeals]     = useState<Appeal[]>([]);
  const [loading,     setLoading]     = useState(true);
  const [filter,      setFilter]      = useState<'all' | 'pending' | 'cleared' | 'upheld'>('pending');
  const [updating,    setUpdating]    = useState<string | null>(null);
  const [expanded,    setExpanded]    = useState<string | null>(null);

  const load = useCallback(() => {
    setLoading(true);
    getAdminAppeals(filter === 'all' ? undefined : filter)
      .then(setAppeals)
      .finally(() => setLoading(false));
  }, [filter]);

  useEffect(() => { load(); }, [load]);

  const act = async (id: string, status: 'cleared' | 'upheld') => {
    setUpdating(id);
    try {
      await updateAppealStatus(id, status);
      setAppeals(prev => prev.map(a => a.id === id ? { ...a, status } : a));
    } finally {
      setUpdating(null);
    }
  };

  const filterStyle = (v: string): React.CSSProperties => ({
    ...mono, fontSize: '0.62rem', letterSpacing: '0.1em', textTransform: 'uppercase',
    background: filter === v ? `${gold}18` : 'transparent',
    border: `1px solid ${filter === v ? borderBright : border}`,
    color: filter === v ? gold : muted,
    padding: '0.3rem 0.85rem', cursor: 'pointer',
  });

  return (
    <div>
      {/* Filter strip */}
      <div style={{ display: 'flex', gap: '0.5rem', marginBottom: '1.5rem' }}>
        {(['pending', 'cleared', 'upheld', 'all'] as const).map(f => (
          <button key={f} onClick={() => setFilter(f)} style={filterStyle(f)}>{f}</button>
        ))}
        <div style={{ marginLeft: 'auto', ...mono, fontSize: '0.65rem', color: dim, alignSelf: 'center' }}>
          {appeals.length} result{appeals.length !== 1 ? 's' : ''}
        </div>
      </div>

      {loading ? (
        <div style={{ ...mono, fontSize: '0.7rem', color: dim, letterSpacing: '0.15em', padding: '3rem', textAlign: 'center' }}>Loading…</div>
      ) : appeals.length === 0 ? (
        <div style={{ ...mono, fontSize: '0.75rem', color: dim, padding: '3rem', textAlign: 'center' }}>No appeals found.</div>
      ) : (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
          {appeals.map(a => (
            <div key={a.id} style={{
              background: bg2, border: `1px solid ${a.status === 'pending' ? 'rgba(201,168,76,0.25)' : border}`,
              transition: 'border-color 0.2s',
            }}>
              {/* Header row */}
              <div
                onClick={() => setExpanded(expanded === a.id ? null : a.id)}
                style={{ display: 'grid', gridTemplateColumns: '1fr 160px 160px 100px 80px', alignItems: 'center', padding: '0.85rem 1.25rem', cursor: 'pointer', gap: '1rem' }}
              >
                <div>
                  <div style={{ ...sans, fontSize: '0.88rem', color: '#F0E8D6', fontWeight: 500, marginBottom: '0.2rem' }}>
                    {a.username ?? <span style={{ color: dim }}>unknown user</span>}
                  </div>
                  <div style={{ ...mono, fontSize: '0.65rem', color: muted }}>{a.slug}</div>
                </div>
                <div style={{ ...mono, fontSize: '0.65rem', color: dim }}>
                  {new Date(a.created_at).toLocaleString()}
                </div>
                <div style={{ ...mono, fontSize: '0.65rem', color: dim, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                  {a.reason}
                </div>
                <Badge color={APPEAL_STATUS_COLORS[a.status]}>{a.status}</Badge>
                <div style={{ ...mono, fontSize: '0.65rem', color: dim, textAlign: 'right' }}>
                  {expanded === a.id ? '▲' : '▼'}
                </div>
              </div>

              {/* Expanded detail */}
              {expanded === a.id && (
                <div style={{ padding: '0 1.25rem 1.25rem', borderTop: `1px solid ${border}` }}>
                  <div style={{ paddingTop: '1rem' }}>
                    <Label>Full reason</Label>
                    <div style={{ ...sans, fontSize: '0.88rem', color: '#D4CCBC', lineHeight: 1.7, background: bg, padding: '0.75rem 1rem', border: `1px solid ${border}`, marginBottom: '1rem' }}>
                      {a.reason}
                    </div>

                    {a.code && (
                      <div style={{ marginBottom: '1rem' }}>
                        <Label>Pasted code — what triggered the ban</Label>
                        <pre style={{
                          ...mono, fontSize: '0.72rem', color: '#D4CCBC',
                          background: bg, border: `1px solid rgba(200,42,42,0.3)`,
                          padding: '0.75rem 1rem', margin: 0,
                          maxHeight: '260px', overflow: 'auto',
                          whiteSpace: 'pre-wrap', wordBreak: 'break-all',
                        }}>
                          {a.code}
                        </pre>
                      </div>
                    )}

                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '1rem', marginBottom: '1rem' }}>
                      <div>
                        <Label>User ID</Label>
                        <div style={{ ...mono, fontSize: '0.65rem', color: muted }}>{a.user_id ?? '—'}</div>
                      </div>
                      <div>
                        <Label>Problem slug</Label>
                        <div style={{ ...mono, fontSize: '0.65rem', color: gold }}>{a.slug}</div>
                      </div>
                      <div>
                        <Label>Submitted</Label>
                        <div style={{ ...mono, fontSize: '0.65rem', color: muted }}>{new Date(a.created_at).toLocaleString()}</div>
                      </div>
                    </div>

                    {a.status === 'pending' && (
                      <div style={{ display: 'flex', gap: '0.75rem' }}>
                        <button
                          onClick={() => act(a.id, 'cleared')}
                          disabled={updating === a.id}
                          style={{ ...mono, fontSize: '0.65rem', letterSpacing: '0.1em', textTransform: 'uppercase', background: 'transparent', border: `1px solid ${green}55`, color: updating === a.id ? dim : green, padding: '0.5rem 1.25rem', cursor: updating === a.id ? 'not-allowed' : 'pointer' }}
                        >
                          ✓ Clear — remove ban
                        </button>
                        <button
                          onClick={() => act(a.id, 'upheld')}
                          disabled={updating === a.id}
                          style={{ ...mono, fontSize: '0.65rem', letterSpacing: '0.1em', textTransform: 'uppercase', background: 'transparent', border: `1px solid ${red}55`, color: updating === a.id ? dim : red, padding: '0.5rem 1.25rem', cursor: updating === a.id ? 'not-allowed' : 'pointer' }}
                        >
                          ✗ Uphold — keep ban
                        </button>
                      </div>
                    )}
                    {a.status !== 'pending' && (
                      <div style={{ ...mono, fontSize: '0.65rem', color: APPEAL_STATUS_COLORS[a.status] }}>
                        Decision: {a.status}
                      </div>
                    )}
                  </div>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

// ── Submissions tab ────────────────────────────────────────────────────────
function SubmissionsTab() {
  const [submissions, setSubmissions] = useState<AdminSubmission[]>([]);
  const [loading,     setLoading]     = useState(true);
  const [slugFilter,  setSlugFilter]  = useState('');
  const [statusFilter,setStatusFilter]= useState('');
  const [userFilter,  setUserFilter]  = useState('');
  const [expanded,    setExpanded]    = useState<string | null>(null);
  const [page,        setPage]        = useState(0);
  const PAGE_SIZE = 50;

  const load = useCallback(() => {
    setLoading(true);
    getAdminSubmissions({
      slug:   slugFilter   || undefined,
      status: statusFilter || undefined,
      user:   userFilter   || undefined,
      offset: page * PAGE_SIZE,
      limit:  PAGE_SIZE,
    })
      .then(setSubmissions)
      .finally(() => setLoading(false));
  }, [slugFilter, statusFilter, userFilter, page]);

  useEffect(() => { load(); }, [load]);

  const inputStyle: React.CSSProperties = {
    ...mono, fontSize: '0.68rem', background: 'transparent',
    border: `1px solid ${border}`, color: '#F0E8D6',
    padding: '0.4rem 0.75rem', outline: 'none', letterSpacing: '0.04em',
  };

  return (
    <div>
      {/* Filters */}
      <div style={{ display: 'flex', gap: '0.75rem', marginBottom: '1.5rem', flexWrap: 'wrap', alignItems: 'center' }}>
        <input
          value={slugFilter} onChange={e => { setSlugFilter(e.target.value); setPage(0); }}
          placeholder="Filter by slug…"
          style={{ ...inputStyle, minWidth: '180px' }}
        />
        <select value={statusFilter} onChange={e => { setStatusFilter(e.target.value); setPage(0); }} style={{ ...inputStyle, cursor: 'pointer' }}>
          <option value="">All statuses</option>
          {Object.keys(SUBMISSION_STATUS_COLORS).map(s => (
            <option key={s} value={s}>{s.replace('_', ' ')}</option>
          ))}
        </select>
        <input
          value={userFilter} onChange={e => { setUserFilter(e.target.value); setPage(0); }}
          placeholder="Filter by username…"
          style={{ ...inputStyle, minWidth: '160px' }}
        />
        <button onClick={load} style={{ ...inputStyle, cursor: 'pointer', color: gold, border: `1px solid ${borderBright}` }}>
          Refresh
        </button>
        <div style={{ marginLeft: 'auto', ...mono, fontSize: '0.65rem', color: dim, alignSelf: 'center' }}>
          {submissions.length} result{submissions.length !== 1 ? 's' : ''}
        </div>
      </div>

      {/* Header */}
      <div style={{ display: 'grid', gridTemplateColumns: '160px 1fr 100px 80px 100px 60px', padding: '0.6rem 1.25rem', background: bg, borderBottom: `1px solid ${border}` }}>
        {['User', 'Problem', 'Language', 'Status', 'Time', 'XP'].map(h => (
          <div key={h} style={{ ...mono, fontSize: '0.58rem', letterSpacing: '0.15em', textTransform: 'uppercase', color: dim }}>{h}</div>
        ))}
      </div>

      {loading ? (
        <div style={{ ...mono, fontSize: '0.7rem', color: dim, letterSpacing: '0.15em', padding: '3rem', textAlign: 'center' }}>Loading…</div>
      ) : submissions.length === 0 ? (
        <div style={{ ...mono, fontSize: '0.75rem', color: dim, padding: '3rem', textAlign: 'center' }}>No submissions found.</div>
      ) : (
        <div>
          {submissions.map((s, i) => {
            const st = SUBMISSION_STATUS_COLORS[s.status];
            return (
              <div key={s.id} style={{ borderBottom: i < submissions.length - 1 ? `1px solid ${border}` : 'none' }}>
                <div
                  onClick={() => setExpanded(expanded === s.id ? null : s.id)}
                  style={{
                    display: 'grid', gridTemplateColumns: '160px 1fr 100px 80px 100px 60px',
                    padding: '0.75rem 1.25rem', cursor: 'pointer', alignItems: 'center',
                    background: expanded === s.id ? `${gold}08` : 'transparent',
                    transition: 'background 0.15s',
                  }}
                  onMouseEnter={e => { if (expanded !== s.id) e.currentTarget.style.background = '#0F0D09'; }}
                  onMouseLeave={e => { if (expanded !== s.id) e.currentTarget.style.background = 'transparent'; }}
                >
                  <div style={{ ...mono, fontSize: '0.68rem', color: muted, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                    {s.username ?? <span style={{ color: dim }}>unknown</span>}
                  </div>
                  <div style={{ ...mono, fontSize: '0.68rem', color: gold }}>{s.problem_slug}</div>
                  <div style={{ ...mono, fontSize: '0.65rem', color: dim }}>{s.language ?? '—'}</div>
                  <div>
                    {st ? <Badge color={st.color}>{s.status.replace('_', ' ')}</Badge> : <span style={{ color: dim, fontSize: '0.65rem' }}>{s.status}</span>}
                  </div>
                  <div style={{ ...mono, fontSize: '0.65rem', color: dim }}>{new Date(s.created_at).toLocaleString()}</div>
                  <div style={{ ...serif, fontSize: '0.8rem', color: s.xp_awarded > 0 ? gold : dim, fontWeight: 600 }}>
                    {s.xp_awarded > 0 ? `+${s.xp_awarded}` : '—'}
                  </div>
                </div>

                {expanded === s.id && (
                  <div style={{ padding: '0 1.25rem 1.25rem', borderTop: `1px solid ${border}`, background: `${gold}05` }}>
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr', gap: '1rem', padding: '1rem 0 0.75rem' }}>
                      <div><Label>Submission ID</Label><div style={{ ...mono, fontSize: '0.6rem', color: dim }}>{s.id}</div></div>
                      <div><Label>User ID</Label><div style={{ ...mono, fontSize: '0.6rem', color: dim }}>{s.user_id}</div></div>
                      <div><Label>Runtime</Label><div style={{ ...mono, fontSize: '0.65rem', color: muted }}>{s.runtime_ms != null ? `${s.runtime_ms}ms` : '—'}</div></div>
                      <div><Label>XP awarded</Label><div style={{ ...serif, fontSize: '0.85rem', color: gold }}>{s.xp_awarded > 0 ? `+${s.xp_awarded}` : '—'}</div></div>
                    </div>

                    {s.output && (
                      <div style={{ marginBottom: '0.75rem' }}>
                        <Label>Output</Label>
                        <pre style={{ ...mono, fontSize: '0.72rem', color: muted, background: bg, border: `1px solid ${border}`, padding: '0.75rem 1rem', margin: 0, overflowX: 'auto', whiteSpace: 'pre-wrap', wordBreak: 'break-all' }}>
                          {s.output}
                        </pre>
                      </div>
                    )}

                    {s.code && (
                      <div>
                        <Label>Code submitted</Label>
                        <pre style={{ ...mono, fontSize: '0.72rem', color: '#D4CCBC', background: bg, border: `1px solid ${border}`, padding: '0.75rem 1rem', margin: 0, overflowX: 'auto', maxHeight: '300px', overflow: 'auto' }}>
                          {s.code}
                        </pre>
                      </div>
                    )}

                    {s.answer && (
                      <div>
                        <Label>Answer submitted</Label>
                        <div style={{ ...mono, fontSize: '0.78rem', color: '#D4CCBC', background: bg, border: `1px solid ${border}`, padding: '0.75rem 1rem' }}>
                          {s.answer}
                        </div>
                      </div>
                    )}

                    {s.test_results && s.test_results.length > 0 && (
                      <div style={{ marginTop: '0.75rem' }}>
                        <Label>Test results</Label>
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '0.3rem' }}>
                          {s.test_results.map((tr: any, j: number) => (
                            <div key={j} style={{ display: 'flex', gap: '0.75rem', padding: '0.3rem 0.75rem', background: tr.passed ? 'rgba(42,200,125,0.04)' : 'rgba(224,92,42,0.04)', border: `1px solid ${tr.passed ? 'rgba(42,200,125,0.12)' : 'rgba(224,92,42,0.12)'}` }}>
                              <span style={{ ...mono, fontSize: '0.6rem', color: tr.passed ? green : '#E05C2A', flexShrink: 0 }}>{tr.passed ? '✓' : '✗'}</span>
                              <span style={{ ...mono, fontSize: '0.6rem', color: dim }}>in: {tr.input}</span>
                              <span style={{ ...mono, fontSize: '0.6rem', color: dim }}>expected: {tr.expected}</span>
                              <span style={{ ...mono, fontSize: '0.6rem', color: tr.passed ? muted : '#E05C2A' }}>got: {tr.actual}</span>
                              {tr.error && <span style={{ ...mono, fontSize: '0.6rem', color: red }}>{tr.error}</span>}
                            </div>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )}
              </div>
            );
          })}

          {/* Pagination */}
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '1rem', padding: '1.25rem', borderTop: `1px solid ${border}` }}>
            <button
              onClick={() => setPage(p => Math.max(0, p - 1))}
              disabled={page === 0}
              style={{ ...mono, fontSize: '0.65rem', letterSpacing: '0.1em', background: 'transparent', border: `1px solid ${border}`, color: page === 0 ? dim : gold, padding: '0.35rem 1rem', cursor: page === 0 ? 'not-allowed' : 'pointer' }}
            >
              ← Prev
            </button>
            <span style={{ ...mono, fontSize: '0.65rem', color: dim }}>Page {page + 1}</span>
            <button
              onClick={() => setPage(p => p + 1)}
              disabled={submissions.length < PAGE_SIZE}
              style={{ ...mono, fontSize: '0.65rem', letterSpacing: '0.1em', background: 'transparent', border: `1px solid ${border}`, color: submissions.length < PAGE_SIZE ? dim : gold, padding: '0.35rem 1rem', cursor: submissions.length < PAGE_SIZE ? 'not-allowed' : 'pointer' }}
            >
              Next →
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

// ── Main page ──────────────────────────────────────────────────────────────
export default function AdminPanel() {
  const [searchParams] = useSearchParams();
  const navigate       = useNavigate();
  const [tab, setTab]  = useState<'appeals' | 'submissions'>('appeals');

  const providedKey = searchParams.get('key');
  const validKey    = process.env.REACT_APP_ADMIN_KEY;

  // Gate: missing or wrong key → redirect silently
  useEffect(() => {
    if (!validKey || providedKey !== validKey) {
      navigate('/', { replace: true });
    }
  }, [providedKey, validKey, navigate]);

  if (!validKey || providedKey !== validKey) return null;

  const tabStyle = (t: string): React.CSSProperties => ({
    ...mono, fontSize: '0.65rem', letterSpacing: '0.12em', textTransform: 'uppercase',
    background: 'none', border: 'none',
    borderBottom: tab === t ? `2px solid ${gold}` : '2px solid transparent',
    color: tab === t ? gold : dim,
    padding: '0.6rem 1.25rem', cursor: 'pointer', marginBottom: '-1px',
  });

  return (
    <div style={{ minHeight: '100vh', background: bg, color: '#F0E8D6' }}>

      {/* Top bar */}
      <div style={{ height: '48px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 2rem', borderBottom: `1px solid ${border}`, background: 'rgba(10,9,6,0.97)', position: 'sticky', top: 0, zIndex: 10 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '1.5rem' }}>
          <a href="/arena" style={{ ...serif, fontSize: '0.9rem', fontWeight: 700, color: gold, textDecoration: 'none', letterSpacing: '0.08em' }}>APOLLO</a>
          <span style={{ color: dim }}>›</span>
          <span style={{ ...mono, fontSize: '0.65rem', letterSpacing: '0.15em', textTransform: 'uppercase', color: muted }}>Owner Panel</span>
        </div>
        <div style={{ ...mono, fontSize: '0.58rem', color: dim, letterSpacing: '0.1em' }}>
          ● authenticated
        </div>
      </div>

      {/* Page header */}
      <div style={{ padding: '2.5rem 2rem 0' }}>
        <div style={{ ...mono, fontSize: '0.6rem', letterSpacing: '0.25em', textTransform: 'uppercase', color: dim, marginBottom: '0.5rem' }}>
          Admin
        </div>
        <h1 style={{ ...serif, fontSize: 'clamp(1.75rem, 3vw, 2.5rem)', fontWeight: 900, margin: '0 0 0.25rem', lineHeight: 1 }}>
          Review <span style={{ color: gold }}>Panel</span>
        </h1>
        <p style={{ ...sans, color: muted, fontSize: '0.9rem', fontWeight: 300, margin: '0.5rem 0 0' }}>
          Anti-cheat appeals and submission records.
        </p>
      </div>

      {/* Tabs */}
      <div style={{ display: 'flex', borderBottom: `1px solid ${border}`, margin: '1.5rem 0 0', padding: '0 2rem' }}>
        <button onClick={() => setTab('appeals')} style={tabStyle('appeals')}>Appeals</button>
        <button onClick={() => setTab('submissions')} style={tabStyle('submissions')}>Submissions</button>
      </div>

      {/* Content */}
      <div style={{ padding: '1.5rem 2rem 4rem' }}>
        {tab === 'appeals'     && <AppealsTab />}
        {tab === 'submissions' && <SubmissionsTab />}
      </div>
    </div>
  );
}