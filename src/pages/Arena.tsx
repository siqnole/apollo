import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faKeyboard, faRadio, faPen, faBug, faArrowsUpDown, faNoteSticky, faServer, faDatabase } from '@fortawesome/free-solid-svg-icons';
import { getProblems, getMe, Problem } from '../services/api';

const DIFFICULTIES = ['All', 'Easy', 'Medium', 'Hard', 'Expert'];
const TYPES: { value: string; label: string }[] = [
  { value: '',               label: 'All Types'       },
  { value: 'code',           label: 'Code'            },
  { value: 'multiple_choice',label: 'Multiple Choice' },
  { value: 'fill_blank',     label: 'Fill in Blank'   },
  { value: 'debug',          label: 'Debug'           },
  { value: 'ordering',       label: 'Ordering'        },
  { value: 'short_answer',   label: 'Short Answer'    },
  { value: 'shell',          label: 'Shell'           },
  { value: 'sql',            label: 'SQL'             },
  { value: 'shell_sql',      label: 'Shell + SQL'     },
];

// Map onboarding interests → problem categories
const INTEREST_TO_CATEGORIES: Record<string, string[]> = {
  'Algorithms':      ['Algorithms', 'Data Structures'],
  'System Design':   ['System Design', 'Systems Programming'],
  'Frontend Dev':    ['Web Development', 'UI/UX'],
  'Backend Dev':     ['Backend Dev', 'Databases', 'Systems Programming'],
  'Machine Learning':['Machine Learning', 'Data Science'],
  'Data Science':    ['Data Science'],
  'Mobile Dev':      ['Mobile Dev'],
  'DevOps':          ['DevOps', 'Sysadmin'],
  'Security':        ['Security'],
  'Databases':       ['Databases'],
  'Game Dev':        ['Game Dev'],
  'UI/UX':           ['UI/UX', 'Web Development'],
  'Cloud':           ['Cloud', 'DevOps'],
  'Blockchain':      ['Blockchain'],
  'Open Source':     ['Algorithms', 'Data Structures'],
  'Physics':         ['Physics'],
  'Chemistry':       ['Chemistry'],
  'Calculus':        ['Calculus I', 'Calculus II', 'Calculus III'],
  'Linear Algebra':  ['Linear Algebra'],
  'Differential Equations': ['Differential Equations'],
};

const DIFF_COLORS: Record<string, string> = {
  Easy:   '#2AC87D',
  Medium: '#C9A84C',
  Hard:   '#E05C2A',
  Expert: '#C82A2A',
};

const HIGH_LEVEL = new Set(['javascript','typescript','python']);
const LOW_LEVEL  = new Set(['c','cpp','csharp']);

function getLangTag(langs: string[]): { label: string; color: string; bg: string } | null {
  if (!langs || langs.length === 0 || langs[0] === 'any') return null;
  if (langs[0] === 'html')  return { label: 'HTML/CSS', color: '#E8C97A', bg: 'rgba(232,201,122,0.12)' };
  if (langs[0] === 'shell') return { label: 'Shell',    color: '#4ADE80', bg: 'rgba(74,222,128,0.12)'  };
  if (langs[0] === 'sql')   return { label: 'SQL',      color: '#60A5FA', bg: 'rgba(96,165,250,0.12)'  };
  const hasHigh = langs.some(l => HIGH_LEVEL.has(l));
  const hasLow  = langs.some(l => LOW_LEVEL.has(l));
  if (hasHigh && hasLow) return { label: 'All Languages', color: '#60A5FA', bg: 'rgba(96,165,250,0.12)' };
  if (hasLow)            return { label: langs.map(l => l === 'csharp' ? 'C#' : l === 'cpp' ? 'C++' : l.toUpperCase()).join('/'), color: '#C084FC', bg: 'rgba(192,132,252,0.12)' };
  return { label: langs.map(l => l === 'javascript' ? 'JS' : l === 'typescript' ? 'TS' : l === 'python' ? 'Py' : l).join('/'), color: '#C9A84C', bg: 'rgba(201,168,76,0.12)' };
}

const TYPE_ICON_MAP: Record<string, any> = {
  code:            faKeyboard,
  multiple_choice: faRadio,
  fill_blank:      faPen,
  debug:           faBug,
  ordering:        faArrowsUpDown,
  short_answer:    faNoteSticky,
  shell:           faServer,
  sql:             faDatabase,
  shell_sql:       faServer,
};

function renderTypeIcon(type: string): React.JSX.Element {
  return <FontAwesomeIcon icon={TYPE_ICON_MAP[type] || faNoteSticky} />;
}

const gold   = '#C9A84C';
const muted  = '#8A7D65';
const dim    = '#4A4236';
const border = 'rgba(201,168,76,0.18)';

export default function Arena() {
  const navigate = useNavigate();
  const [problems,       setProblems]       = useState<Problem[]>([]);
  const [loading,        setLoading]        = useState(true);
  const [search,         setSearch]         = useState('');
  const [difficulty,     setDifficulty]     = useState('All');
  const [type,           setType]           = useState('');
  const [categories,     setCategories]     = useState<string[]>([]);
  const [category,       setCategory]       = useState('');
  const [myCategories,   setMyCategories]   = useState<Set<string>>(new Set());
  const [showAll,        setShowAll]        = useState(false);
  const [showSolved,     setShowSolved]     = useState(false);

  useEffect(() => {
    Promise.all([getProblems(), getMe()])
      .then(([ps, me]) => {
        setProblems(ps);
        const cats = Array.from(new Set(ps.map(p => p.category))).sort();
        setCategories(cats);

        // Derive relevant categories from user's interests
        const relevant = new Set<string>();
        for (const interest of me.interests) {
          const mapped = INTEREST_TO_CATEGORIES[interest] ?? [];
          for (const cat of mapped) relevant.add(cat);
        }
        setMyCategories(relevant);
      })
      .finally(() => setLoading(false));
  }, []);

  const filtered = problems.filter(p => {
    if (!showAll && myCategories.size > 0 && !myCategories.has(p.category)) return false;
    if (difficulty !== 'All' && p.difficulty !== difficulty) return false;
    if (type && p.problem_type !== type) return false;
    if (category && p.category !== category) return false;
    if (search && !p.title.toLowerCase().includes(search.toLowerCase())) return false;
    if (!showSolved && p.solved) return false;
    return true;
  });

  const inputStyle: React.CSSProperties = {
    background: 'transparent', border: `1px solid ${border}`, color: '#F0E8D6',
    padding: '0.5rem 0.85rem', fontFamily: 'DM Mono, monospace', fontSize: '0.72rem',
    outline: 'none', letterSpacing: '0.05em',
  };

  return (
    <div style={{ minHeight: '100vh', background: '#0A0906', color: '#F0E8D6' }}>

      {/* Nav */}
      <nav style={{ position: 'fixed', top: 0, left: 0, right: 0, zIndex: 100, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '1.25rem 3rem', background: 'rgba(10,9,6,0.9)', backdropFilter: 'blur(12px)', borderBottom: `1px solid ${border}` }}>
        <a href="/" style={{ fontFamily: 'Cinzel, serif', fontSize: '1.2rem', fontWeight: 700, color: gold, textDecoration: 'none', letterSpacing: '0.1em' }}>
          APOLLO<span style={{ color: muted, fontWeight: 400 }}>.gg</span>
        </a>
        <div style={{ display: 'flex', gap: '1.5rem', alignItems: 'center' }}>
          <button onClick={() => navigate('/dashboard')} style={{ ...inputStyle, cursor: 'pointer' }}>← Dashboard</button>
        </div>
      </nav>

      <main style={{ maxWidth: '1100px', margin: '0 auto', padding: '8rem 3rem 6rem' }}>

        {/* Header */}
        <div style={{ marginBottom: '3rem' }}>
          <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', letterSpacing: '0.25em', textTransform: 'uppercase' as const, color: dim, marginBottom: '0.75rem' }}>Challenges</div>
          <h1 style={{ fontFamily: 'Cinzel, serif', fontSize: 'clamp(2rem, 5vw, 3rem)', fontWeight: 900, lineHeight: 1, margin: 0 }}>
            The <span style={{ color: gold }}>Arena</span>
          </h1>
          <div style={{ display: 'flex', alignItems: 'center', gap: '1.5rem', marginTop: '0.75rem' }}>
            <p style={{ color: muted, fontSize: '0.95rem', fontWeight: 300, margin: 0 }}>
              {filtered.length} challenge{filtered.length !== 1 ? 's' : ''}{!showAll && myCategories.size > 0 ? ' in your arenas' : ''}.
            </p>
            {myCategories.size > 0 && (
              <button
                onClick={() => setShowAll(v => !v)}
                style={{
                  background: 'transparent', border: `1px solid ${border}`,
                  color: showAll ? muted : gold, fontFamily: 'DM Mono, monospace',
                  fontSize: '0.65rem', letterSpacing: '0.1em', textTransform: 'uppercase' as const,
                  padding: '0.3rem 0.75rem', cursor: 'pointer',
                }}
              >
                {showAll ? 'My Arenas' : 'Show All'}
              </button>
            )}
          </div>
        </div>

        {/* Active arena tags */}
        {!showAll && myCategories.size > 0 && (
          <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' as const, marginBottom: '1.5rem' }}>
            {Array.from(myCategories).sort().map(cat => (
              <span key={cat} style={{
                fontFamily: 'DM Mono, monospace', fontSize: '0.62rem', letterSpacing: '0.08em',
                color: gold, border: `1px solid rgba(201,168,76,0.35)`, padding: '0.2rem 0.6rem',
                background: 'rgba(201,168,76,0.07)',
              }}>
                {cat}
              </span>
            ))}
          </div>
        )}

        {/* Filters */}
        <div style={{ display: 'flex', gap: '0.75rem', marginBottom: '2rem', flexWrap: 'wrap' as const, alignItems: 'center' }}>
          <input
            value={search} onChange={e => setSearch(e.target.value)}
            placeholder="Search problems…"
            style={{ ...inputStyle, minWidth: '200px', flex: 1 }}
          />
          <select value={difficulty} onChange={e => setDifficulty(e.target.value)} style={{ ...inputStyle, cursor: 'pointer' }}>
            {DIFFICULTIES.map(d => <option key={d} value={d}>{d}</option>)}
          </select>
          <select value={type} onChange={e => setType(e.target.value)} style={{ ...inputStyle, cursor: 'pointer' }}>
            {TYPES.map(t => <option key={t.value} value={t.value}>{t.label}</option>)}
          </select>
          <select value={category} onChange={e => setCategory(e.target.value)} style={{ ...inputStyle, cursor: 'pointer' }}>
            <option value="">All Categories</option>
            {categories.map(c => <option key={c} value={c}>{c}</option>)}
          </select>
          <select value={showSolved ? 'all' : 'unsolved'} onChange={e => setShowSolved(e.target.value === 'all')} style={{ ...inputStyle, cursor: 'pointer' }}>
            <option value="unsolved">Unsolved</option>
            <option value="all">All</option>
          </select>
        </div>

        {/* Problem list */}
        {loading ? (
          <div style={{ textAlign: 'center' as const, padding: '4rem', fontFamily: 'DM Mono, monospace', fontSize: '0.75rem', color: dim, letterSpacing: '0.2em', textTransform: 'uppercase' as const }}>Loading challenges…</div>
        ) : filtered.length === 0 ? (
          <div style={{ textAlign: 'center' as const, padding: '4rem', fontFamily: 'Cinzel, serif', color: dim }}>
            No problems match your filters.
            {!showAll && myCategories.size > 0 && (
              <div style={{ marginTop: '1rem' }}>
                <button onClick={() => setShowAll(true)} style={{ ...inputStyle, cursor: 'pointer', color: gold }}>
                  Show all challenges →
                </button>
              </div>
            )}
          </div>
        ) : (
          <div style={{ border: `1px solid ${border}` }}>
            {/* Header row */}
            <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 1fr 80px 80px', padding: '0.75rem 1.5rem', borderBottom: `1px solid ${border}`, background: '#0F0D09' }}>
              {['Problem', 'Category', 'Type', 'XP', 'Solves'].map(h => (
                <div key={h} style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.15em', textTransform: 'uppercase' as const, color: dim }}>{h}</div>
              ))}
            </div>
            {filtered.map((p, i) => (
              <div
                key={p.id}
                onClick={() => navigate(`/arena/${p.slug}`)}
                style={{ display: 'grid', gridTemplateColumns: '2fr 1fr 1fr 80px 80px', padding: '1rem 1.5rem', borderBottom: i < filtered.length - 1 ? `1px solid ${border}` : 'none', cursor: 'pointer', transition: 'background 0.15s', background: 'transparent' }}
                onMouseEnter={e => (e.currentTarget.style.background = '#0F0D09')}
                onMouseLeave={e => (e.currentTarget.style.background = 'transparent')}
              >
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem', marginBottom: '0.2rem' }}>
                    <span style={{ fontFamily: 'DM Sans, sans-serif', fontSize: '0.9rem', fontWeight: 500, color: '#F0E8D6' }}>{p.title}</span>
                    <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.05em', color: DIFF_COLORS[p.difficulty], border: `1px solid ${DIFF_COLORS[p.difficulty]}33`, padding: '0.1rem 0.4rem' }}>{p.difficulty}</span>
                    {(() => { const t = getLangTag(p.supported_languages); return t ? <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.05em', color: t.color, background: t.bg, border: `1px solid ${t.color}33`, padding: '0.1rem 0.4rem' }}>{t.label}</span> : null; })()}
                  </div>
                  <div style={{ display: 'flex', gap: '0.4rem', flexWrap: 'wrap' as const }}>
                    {(p.tags || []).slice(0, 3).map(t => (
                      <span key={t} style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', color: dim, letterSpacing: '0.05em' }}>#{t}</span>
                    ))}
                  </div>
                </div>
                <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.72rem', color: muted, alignSelf: 'center' as const }}>{p.category}</div>
                <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.75rem', color: muted, alignSelf: 'center' as const }}>
                  {renderTypeIcon(p.problem_type)} | {p.problem_type.replace('_', ' ')}
                </div>
                <div style={{ fontFamily: 'Cinzel, serif', fontSize: '0.9rem', fontWeight: 600, color: gold, alignSelf: 'center' as const }}>+{p.xp_reward}</div>
                <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.72rem', color: dim, alignSelf: 'center' as const }}>{p.solve_count || 0}</div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}