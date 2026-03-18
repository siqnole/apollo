import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
// Remove faSwords, faColosseum — replace with free equivalents
import { faCompass, faDumbbell, faBuilding, faCrown, faBullseye, faChartLine, faLink, faTrophy, faKeyboard, faRadio, faPen, faBug, faArrowsUpDown, faNoteSticky } from '@fortawesome/free-solid-svg-icons';
import { getMe, getRivals, UserProfile, Rival } from '../services/api';
import EditProfileModal from '../components/dashboard/EditProfileModal';

// ── XP thresholds ──────────────────────────────────────────────────────────
const RANK_XP: Record<string, { min: number; max: number; next: string | null }> = {
  Explorer:  { min: 0,    max: 500,  next: 'Contender' },
  Contender: { min: 500,  max: 2000, next: 'Gladiator' },
  Gladiator: { min: 2000, max: 5000, next: 'Champion'  },
  Champion:  { min: 5000, max: 5000, next: null         },
};

const RANK_ICON_MAP: Record<string, any> = {
  Explorer:  faCompass,
  Contender: faDumbbell,
  Gladiator: faBuilding,
  Champion:  faCrown,
};

function renderRankIcon(rank: string): React.JSX.Element {
  return <FontAwesomeIcon icon={RANK_ICON_MAP[rank] || faCompass} />;
}

function xpPercent(xp: number, rank: string): number {
  const tier = RANK_XP[rank];
  if (!tier || tier.next === null) return 100; // max rank
  const range = tier.max - tier.min;
  if (range <= 0) return 0;
  return Math.min(100, Math.max(0, Math.round(((xp - tier.min) / range) * 100)));
}

function initials(username?: string): string {
  if (!username) return 'XX';
  return username.slice(0, 2).toUpperCase();
}

const AVATAR_COLORS = ['#C9A84C','#E05C2A','#2A7DC8','#2AC87D','#7D2AC8','#C82A2A','#C8922A','#2AC8C8'];
function avatarColor(username?: string): string {
  if (!username) return AVATAR_COLORS[0];
  let hash = 0;
  for (const c of username) hash = c.charCodeAt(0) + ((hash << 5) - hash);
  return AVATAR_COLORS[Math.abs(hash) % AVATAR_COLORS.length];
}

function StatCard({ label, value, sub }: { label: string; value: React.ReactNode; sub?: string }) {
  return (
    <div style={{ border: '1px solid rgba(201,168,76,0.18)', padding: 'clamp(1rem, 2vw, 1.5rem) clamp(1rem, 3vw, 2rem)', flex: 1, minWidth: 'clamp(120px, 50vw, 140px)' }}>
      <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: '#7A6230', marginBottom: '0.5rem' }}>{label}</div>
      <div style={{ fontFamily: 'Cinzel, serif', fontSize: 'clamp(1.2rem, 4vw, 2rem)', fontWeight: 700, color: '#C9A84C', lineHeight: 1 }}>{value}</div>
      {sub && <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: '#4A4236', marginTop: '0.35rem', letterSpacing: '0.1em' }}>{sub}</div>}
    </div>
  );
}

const DIFF_COLORS: Record<string, string> = {
  Easy: '#2AC87D', Medium: '#C9A84C', Hard: '#E05C2A', Expert: '#C82A2A',
};

const TYPE_ICON_MAP: Record<string, any> = {
  code: faKeyboard, multiple_choice: faRadio, fill_blank: faPen, debug: faBug, ordering: faArrowsUpDown, short_answer: faNoteSticky,
};

function renderTypeIcon(type: string): React.JSX.Element {
  return <FontAwesomeIcon icon={TYPE_ICON_MAP[type] || faNoteSticky} />;
}

function SolvedCard({ profile }: { profile: UserProfile }) {
  const byDiff: Record<string, number> = (profile as any).solved_by_difficulty ?? {};
  const byType: Record<string, number> = (profile as any).solved_by_type ?? {};
  const total = (profile as any).problems_solved ?? Object.values(byDiff).reduce((a: number, b: number) => a + b, 0);

  return (
    <div style={{ border: '1px solid rgba(201,168,76,0.18)', padding: '1.5rem 2rem', flex: 1, minWidth: '180px' }}>
      <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: '#7A6230', marginBottom: '0.5rem' }}>Solved</div>
      <div style={{ fontFamily: 'Cinzel, serif', fontSize: '2rem', fontWeight: 700, color: '#C9A84C', lineHeight: 1, marginBottom: '0.75rem' }}>{total}</div>
      <div style={{ display: 'flex', gap: '0.6rem', flexWrap: 'wrap' as const, marginBottom: '0.4rem' }}>
        {(['Easy','Medium','Hard','Expert'] as const).map(d => (
          <span key={d} style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', color: DIFF_COLORS[d], letterSpacing: '0.04em' }}>
            {d[0]}<span style={{ color: '#F0E8D6', fontWeight: 600 }}>{byDiff[d] ?? 0}</span>
          </span>
        ))}
      </div>
      {Object.keys(byType).length > 0 && (
        <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' as const }}>
          {Object.entries(byType).map(([t, n]) => n > 0 ? (
            <span key={t} title={t.replace('_',' ')} style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', color: '#4A4236', letterSpacing: '0.04em' }}>
              {renderTypeIcon(t)} | <span style={{ color: '#8A7D65' }}>{n}</span>
            </span>
          ) : null)}
        </div>
      )}
    </div>
  );
}

function RivalCard({ rival }: { rival: Rival & { rank: string } }) {
  const pct = xpPercent(rival.xp, rival.rank);
  return (
    <div
      style={{ border: '1px solid rgba(201,168,76,0.18)', padding: '1.25rem 1.5rem', display: 'flex', alignItems: 'center', gap: '1rem', background: '#0F0D09', cursor: 'default' }}
      onMouseEnter={e => (e.currentTarget.style.borderColor = 'rgba(201,168,76,0.4)')}
      onMouseLeave={e => (e.currentTarget.style.borderColor = 'rgba(201,168,76,0.18)')}
    >
      <div style={{ width: '42px', height: '42px', borderRadius: '50%', background: avatarColor(rival.username), display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: 'DM Mono, monospace', fontSize: '0.75rem', fontWeight: 500, color: '#fff', flexShrink: 0, border: '2px solid rgba(201,168,76,0.3)' }}>
        {initials(rival.username)}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.25rem' }}>
          <span style={{ fontFamily: 'Cinzel, serif', fontSize: '0.9rem', fontWeight: 600, color: '#F0E8D6' }}>{rival.username}</span>
          <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', color: '#7A6230', textTransform: 'uppercase' as const, letterSpacing: '0.1em' }}>
            {renderRankIcon(rival.rank)} {rival.rank}
          </span>
        </div>
        {rival.niche && <div style={{ fontSize: '0.75rem', color: '#8A7D65', marginBottom: '0.4rem', whiteSpace: 'nowrap' as const, overflow: 'hidden', textOverflow: 'ellipsis' }}>{rival.niche}</div>}
        <div style={{ height: '3px', background: 'rgba(201,168,76,0.1)', borderRadius: '2px' }}>
          <div style={{ height: '100%', width: `${pct}%`, background: '#C9A84C', borderRadius: '2px', transition: 'width 0.6s ease' }} />
        </div>
      </div>
      <div style={{ textAlign: 'right' as const, flexShrink: 0 }}>
        <div style={{ fontFamily: 'Cinzel, serif', fontSize: '1rem', fontWeight: 700, color: '#C9A84C' }}>{rival.xp}</div>
        <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.55rem', color: '#4A4236', textTransform: 'uppercase' as const, letterSpacing: '0.1em' }}>XP</div>
      </div>
    </div>
  );
}

export default function Dashboard() {
  const navigate  = useNavigate();
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [rivals,  setRivals]  = useState<(Rival & { rank: string })[]>([]);
  const [loading, setLoading] = useState(true);
  const [error,   setError]   = useState<string | null>(null);
  const [editing, setEditing] = useState(false);
  const [rankModal, setRankModal] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('apollo_token');
    if (!token) { navigate('/'); return; }
    Promise.all([getMe(), getRivals()])
      .then(([me, rv]) => { setProfile(me); setRivals(rv as any); })
      .catch(() => setError('Failed to load your profile.'))
      .finally(() => setLoading(false));
  }, [navigate]);

  const loadingMessages = [
    'Talking with your coach…',
    'Wobbling to your corner…',
    'Catching your breath…',
    'Getting the crowd hyped…',
    'Moving in silence...',
    'Sharpening your skills...',
    'Sizing up the competition...',
    'Getting my game face on...'
  ];
  const loadingMsg = loadingMessages[Math.floor(Math.random() * loadingMessages.length)];

  if (loading) return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#0A0906' }}>
      <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.75rem', color: '#7A6230', letterSpacing: '0.2em', textTransform: 'uppercase' as const }}>{loadingMsg}</div>
    </div>
  );

  if (error || !profile) return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#0A0906' }}>
      <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.75rem', color: '#E05C2A' }}>{error ?? 'Something went wrong.'}</div>
    </div>
  );

  // Ensure required arrays exist
  const safeProfile = {
    ...profile,
    interests: Array.isArray(profile.interests) ? profile.interests : [],
    goals: Array.isArray(profile.goals) ? profile.goals : [],
    socials: Array.isArray(profile.socials) ? profile.socials : [],
  };

  const rank     = safeProfile.rank;
  const pct      = xpPercent(safeProfile.xp, rank);
  const tier     = RANK_XP[rank] ?? { min: 0, max: 500, next: 'Contender' };
  const isMaxRank = tier.next === null;

  return (
    <>
    <div style={{ minHeight: '100vh', background: '#0A0906', color: '#F0E8D6' }}>

      {/* Nav */}
      <nav style={{ position: 'fixed', top: 0, left: 0, right: 0, zIndex: 100, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '1.25rem 3rem', background: 'rgba(10,9,6,0.9)', backdropFilter: 'blur(12px)', borderBottom: '1px solid rgba(201,168,76,0.15)' }}>
        <a href="/" style={{ fontFamily: 'Cinzel, serif', fontSize: '1.2rem', fontWeight: 700, color: '#C9A84C', textDecoration: 'none', letterSpacing: '0.1em' }}>
          APOLLO<span style={{ color: '#8A7D65', fontWeight: 400 }}>.gg</span>
        </a>
        <div style={{ display: 'flex', alignItems: 'center', gap: '1.5rem' }}>
          <button onClick={() => setRankModal(true)} style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', color: '#8A7D65', letterSpacing: '0.1em', background: 'transparent', border: 'none', cursor: 'pointer', padding: 0, transition: 'color 0.15s' }}
            onMouseEnter={e => (e.currentTarget.style.color = '#C9A84C')}
            onMouseLeave={e => (e.currentTarget.style.color = '#8A7D65')}
          >
            {renderRankIcon(rank)} {rank}
          </button>
          <div style={{ width: '34px', height: '34px', borderRadius: '50%', background: avatarColor(safeProfile.username), display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', fontWeight: 500, color: '#fff', border: '2px solid rgba(201,168,76,0.4)' }}>
            {initials(safeProfile.username)}
          </div>
          <button onClick={() => navigate('/arena')} style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', letterSpacing: '0.1em', textTransform: 'uppercase' as const, background: 'transparent', border: '1px solid rgba(201,168,76,0.25)', color: '#7A6230', padding: '0.4rem 0.9rem', cursor: 'pointer' }}>
            The Ring ⚔
          </button>
          <button onClick={() => { localStorage.removeItem('apollo_token'); navigate('/'); }} style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', letterSpacing: '0.1em', textTransform: 'uppercase' as const, background: 'transparent', border: '1px solid rgba(201,168,76,0.2)', color: '#4A4236', padding: '0.4rem 0.9rem', cursor: 'pointer' }}>
            Leave The Ring
          </button>
        </div>
      </nav>

      <main style={{ maxWidth: '1100px', margin: '0 auto', padding: 'clamp(5rem, 8vw, 8rem) clamp(1rem, 3vw, 3rem) 6rem' }}>

        {/* Header */}
        <div style={{ marginBottom: '3rem' }}>
          <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', letterSpacing: '0.25em', textTransform: 'uppercase' as const, color: '#7A6230', marginBottom: '0.75rem' }}>Welcome</div>
          <h1 style={{ fontFamily: 'Cinzel, serif', fontSize: 'clamp(2rem, 5vw, 3.5rem)', fontWeight: 900, lineHeight: 1, margin: 0 }}>
            Hey <span style={{ color: '#C9A84C' }}>{safeProfile.username}</span>, ready to compete?  
          </h1>
          {safeProfile.niche && <p style={{ color: '#8A7D65', fontSize: '0.95rem', marginTop: '0.75rem', fontWeight: 300 }}>{safeProfile.niche}</p>}
        </div>

        {/* Stats */}
        <div style={{ display: 'flex', gap: '1px', background: 'rgba(201,168,76,0.18)', border: '1px solid rgba(201,168,76,0.18)', marginBottom: '3rem', flexWrap: 'wrap' as const }}>
          <StatCard label="Rank"      value={renderRankIcon(rank)} sub={`skill tier: ${safeProfile.skill_tier}`} />
          <StatCard label="XP"        value={safeProfile.xp} sub={`${tier.min}–${tier.max ?? '∞'} range`} />
          <SolvedCard profile={safeProfile} />
          <StatCard label="Interests" value={safeProfile.interests.length} sub="active rings" />
        </div>

        {/* XP Bar */}
        <div style={{ marginBottom: '3rem', border: '1px solid rgba(201,168,76,0.18)', padding: '1.75rem 2rem' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: '1rem' }}>
            <div>
              <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: '#7A6230', marginBottom: '0.3rem' }}>
                {isMaxRank ? 'Rank status' : 'Progress to next rank'}
              </div>
              <div style={{ fontFamily: 'Cinzel, serif', fontSize: '1rem', fontWeight: 600 }}>
                {isMaxRank ? <>{renderRankIcon(rank)} | Max Rank Achieved</> : `${rank} → ${tier.next}`}
              </div>
            </div>
            <div style={{ fontFamily: 'Cinzel, serif', fontSize: '1.5rem', fontWeight: 700, color: '#C9A84C' }}>
              {isMaxRank ? '★' : `${pct}%`}
            </div>
          </div>
          <div style={{ height: '6px', background: 'rgba(201,168,76,0.1)', borderRadius: '3px' }}>
            <div style={{ height: '100%', width: `${pct}%`, background: isMaxRank ? 'linear-gradient(90deg, #C9A84C, #E8C97A)' : 'linear-gradient(90deg, #7A6230, #C9A84C)', borderRadius: '3px', transition: 'width 1s ease' }} />
          </div>
          {!isMaxRank && (
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '0.5rem' }}>
              <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', color: '#4A4236' }}>{tier.min} XP</span>
              <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', color: '#4A4236' }}>{tier.max} XP</span>
            </div>
          )}
        </div>

        {/* Rivals + Sidebar */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 360px', gap: '2rem', alignItems: 'start' }}>
          <div>
            <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: '#7A6230', marginBottom: '1.25rem' }}>
              Your Rivals · {rivals.length} matched
            </div>
            {rivals.length === 0 ? (
              <div style={{ border: '1px solid rgba(201,168,76,0.18)', padding: '3rem', textAlign: 'center' as const }}>
                <div style={{ fontSize: '2rem', marginBottom: '1rem' }}><FontAwesomeIcon icon={faDumbbell} /></div>
                <div style={{ fontFamily: 'Cinzel, serif', fontSize: '1rem', color: '#4A4236', marginBottom: '0.5rem' }}>No rivals yet</div>
                <div style={{ fontSize: '0.85rem', color: '#4A4236', fontWeight: 300 }}>Rivals appear as other challengers join with similar interests and skill tier.</div>
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column' as const, gap: '1px', background: 'rgba(201,168,76,0.1)' }}>
                {rivals.map(r => <RivalCard key={r.id} rival={r} />)}
              </div>
            )}
          </div>

          <div style={{ display: 'flex', flexDirection: 'column' as const, gap: '1.5rem' }}>
            <div style={{ border: '1px solid rgba(201,168,76,0.18)', padding: '1.5rem' }}>
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1rem' }}>
                <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: '#7A6230' }}>My Rings</div>
                <button onClick={() => setEditing(true)} style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.1em', textTransform: 'uppercase' as const, background: 'transparent', border: '1px solid rgba(201,168,76,0.25)', color: '#7A6230', padding: '0.25rem 0.65rem', cursor: 'pointer', transition: 'all 0.2s' }}
                  onMouseEnter={e => { e.currentTarget.style.borderColor = 'rgba(201,168,76,0.5)'; e.currentTarget.style.color = '#C9A84C'; }}
                  onMouseLeave={e => { e.currentTarget.style.borderColor = 'rgba(201,168,76,0.25)'; e.currentTarget.style.color = '#7A6230'; }}
                >
                  Edit
                </button>
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap' as const, gap: '0.5rem' }}>
                {safeProfile.interests.filter(Boolean).map(i => (
                  <span key={i} style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', letterSpacing: '0.05em', padding: '0.3rem 0.75rem', border: '1px solid rgba(201,168,76,0.25)', color: '#8A7D65', textTransform: 'uppercase' as const }}>{i}</span>
                ))}
              </div>
            </div>

            <div style={{ border: '1px solid rgba(201,168,76,0.18)', padding: '1.5rem' }}>
              <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: '#7A6230', marginBottom: '1rem' }}>My Goals</div>
              {safeProfile.goals.length === 0
                ? <div style={{ fontSize: '0.8rem', color: '#4A4236', fontWeight: 300 }}>No goals set.</div>
                : <div style={{ display: 'flex', flexDirection: 'column' as const, gap: '0.6rem' }}>
                    {safeProfile.goals.filter(Boolean).map(g => (
                      <div key={g} style={{ display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
                        <div style={{ width: '6px', height: '6px', background: '#C9A84C', flexShrink: 0 }} />
                        <span style={{ fontSize: '0.85rem', color: '#F0E8D6', fontWeight: 300 }}>{g}</span>
                      </div>
                    ))}
                  </div>
              }
            </div>

            {safeProfile.socials.length > 0 && (
              <div style={{ border: '1px solid rgba(201,168,76,0.18)', padding: '1.5rem' }}>
                <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: '#7A6230', marginBottom: '1rem' }}>Connected</div>
                <div style={{ display: 'flex', flexDirection: 'column' as const, gap: '0.5rem' }}>
                  {safeProfile.socials.filter(Boolean).map(s => (
                    <div key={s.platform} style={{ display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
                      <div style={{ width: '6px', height: '6px', background: s.connected ? '#2AC87D' : '#4A4236', flexShrink: 0 }} />
                      <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', color: s.connected ? '#8A7D65' : '#4A4236', textTransform: 'uppercase' as const, letterSpacing: '0.1em' }}>{s.platform} {s.connected ? '✓' : 'not connected'}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
    {rankModal && safeProfile && (
      <div onClick={() => setRankModal(false)} style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)', zIndex: 200, display: 'flex', alignItems: 'center', justifyContent: 'center', backdropFilter: 'blur(4px)' }}>
        <div onClick={e => e.stopPropagation()} style={{ background: '#0F0D09', border: '1px solid rgba(201,168,76,0.3)', padding: '2.5rem', width: '100%', maxWidth: '480px', position: 'relative' }}>
          <button onClick={() => setRankModal(false)} style={{ position: 'absolute', top: '1rem', right: '1rem', background: 'transparent', border: 'none', color: '#4A4236', fontSize: '1.1rem', cursor: 'pointer', lineHeight: 1 }}>✕</button>
              <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: '#7A6230', marginBottom: '0.5rem' }}>Your Path</div>
          <div style={{ fontFamily: 'Cinzel, serif', fontSize: '1.4rem', fontWeight: 700, color: '#C9A84C', marginBottom: '2rem' }}>
            {renderRankIcon(safeProfile.rank)} {safeProfile.rank} · {safeProfile.xp} XP
          </div>
          <div style={{ display: 'flex', flexDirection: 'column' as const, gap: '0' }}>
            {Object.entries(RANK_XP).map(([r, t], idx) => {
              const isCurrentRank = r === safeProfile.rank;
              const isPast = Object.keys(RANK_XP).indexOf(r) < Object.keys(RANK_XP).indexOf(safeProfile.rank);
              const isFuture = !isCurrentRank && !isPast;
              const rankPct = isPast ? 100 : isCurrentRank ? xpPercent(safeProfile.xp, r) : 0;
              return (
                <div key={r} style={{ padding: '1.25rem 0', borderBottom: idx < Object.keys(RANK_XP).length - 1 ? '1px solid rgba(201,168,76,0.08)' : 'none', opacity: isFuture ? 0.4 : 1 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: isCurrentRank ? '0.75rem' : '0.25rem' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.6rem' }}>
                      <span style={{ fontSize: '1.1rem' }}>{renderRankIcon(r)}</span>
                      <span style={{ fontFamily: 'Cinzel, serif', fontSize: '0.95rem', fontWeight: isCurrentRank ? 700 : 400, color: isCurrentRank ? '#C9A84C' : isPast ? '#8A7D65' : '#4A4236' }}>{r}</span>
                      {isCurrentRank && <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.55rem', letterSpacing: '0.15em', color: '#C9A84C', border: '1px solid rgba(201,168,76,0.4)', padding: '0.1rem 0.4rem' }}>you are here</span>}
                      {isPast && <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.55rem', color: '#2AC87D' }}>✓</span>}
                    </div>
                    <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: '#4A4236' }}>
                      {t.next === null ? `${t.min}+ XP` : `${t.min} – ${t.max} XP`}
                    </span>
                  </div>
                  {isCurrentRank && (
                    <>
                      <div style={{ height: '4px', background: 'rgba(201,168,76,0.1)', borderRadius: '2px', marginBottom: '0.4rem' }}>
                        <div style={{ height: '100%', width: `${rankPct}%`, background: 'linear-gradient(90deg, #7A6230, #C9A84C)', borderRadius: '2px', transition: 'width 0.8s ease' }} />
                      </div>
                      <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                        <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.58rem', color: '#4A4236' }}>{safeProfile.xp} XP</span>
                        {t.next && <span style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.58rem', color: '#4A4236' }}>{t.max - safeProfile.xp} XP to {t.next}</span>}
                      </div>
                    </>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </div>
    )}
    {editing && safeProfile && (
      <EditProfileModal
        profile={safeProfile!}
        onClose={() => setEditing(false)}
        onSaved={(updated) => setProfile(updated)}
      />
    )}
    </>
  );
}