import React, { useState, useEffect } from 'react';
import { UserProfile, updateMe } from '../../services/api';
import { INTERESTS, LEVELS, GOALS } from '../../types/onboarding';

interface Props {
  profile: UserProfile;
  onClose: () => void;
  onSaved: (updated: UserProfile) => void;
}

const gold        = '#C9A84C';
const muted       = '#8A7D65';
const dim         = '#4A4236';
const border      = 'rgba(201,168,76,0.18)';
const borderBright= 'rgba(201,168,76,0.4)';
const surface     = '#1C1812';
const bg          = '#0A0906';

type Tab = 'profile' | 'interests' | 'level' | 'goals';
const TABS: { id: Tab; label: string }[] = [
  { id: 'profile',   label: 'Profile'    },
  { id: 'interests', label: 'Interests'  },
  { id: 'level',     label: 'Skill Tier' },
  { id: 'goals',     label: 'Goals'      },
];

export default function EditProfileModal({ profile, onClose, onSaved }: Props) {
  const [tab,       setTab]       = useState<Tab>('profile');
  const [username,  setUsername]  = useState(profile.username);
  const [niche,     setNiche]     = useState(profile.niche ?? '');
  const [bio,       setBio]       = useState(profile.bio ?? '');
  const [skillTier, setSkillTier] = useState(profile.skill_tier);
  const [interests, setInterests] = useState<string[]>(profile.interests);
  const [goals,     setGoals]     = useState<string[]>(profile.goals);
  const [saving,    setSaving]    = useState(false);
  const [error,     setError]     = useState<string | null>(null);

  useEffect(() => {
    const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [onClose]);

  const toggleInterest = (i: string) =>
    setInterests(prev => prev.includes(i) ? prev.filter(x => x !== i) : prev.length < 8 ? [...prev, i] : prev);

  const toggleGoal = (g: string) =>
    setGoals(prev => prev.includes(g) ? prev.filter(x => x !== g) : prev.length < 3 ? [...prev, g] : prev);

  const handleSave = async () => {
    setError(null);
    if (username.length < 3)   { setError('Username must be at least 3 characters'); return; }
    if (interests.length < 3)  { setError('Pick at least 3 interests'); return; }
    if (goals.length < 1)      { setError('Pick at least one goal'); return; }
    setSaving(true);
    try {
      const updated = await updateMe({
        username:   username.toLowerCase(),
        niche:      niche || undefined,
        bio:        bio || undefined,
        skill_tier: skillTier,
        interests,
        goals,
      });
      onSaved(updated);
      onClose();
    } catch (err: any) {
      setError(err?.response?.data?.error ?? 'Failed to save');
    } finally {
      setSaving(false);
    }
  };

  const inputStyle: React.CSSProperties = { width: '100%', background: 'transparent', border: `1px solid ${border}`, color: '#F0E8D6', padding: '0.6rem 0.85rem', fontFamily: 'DM Sans, sans-serif', fontSize: '0.9rem', outline: 'none', boxSizing: 'border-box' };
  const labelStyle: React.CSSProperties = { display: 'block', fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.15em', textTransform: 'uppercase' as const, color: muted, marginBottom: '0.4rem' };

  return (
    <>
      <div onClick={onClose} style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.75)', zIndex: 200, backdropFilter: 'blur(4px)' }} />
      <div style={{ position: 'fixed', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', zIndex: 201, width: '100%', maxWidth: '560px', maxHeight: '90vh', background: surface, border: `1px solid ${borderBright}`, display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>

        {/* Header */}
        <div style={{ padding: '1.5rem 2rem', borderBottom: `1px solid ${border}`, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div>
            <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.2em', textTransform: 'uppercase' as const, color: dim, marginBottom: '0.25rem' }}>Edit Profile</div>
            <div style={{ fontFamily: 'Cinzel, serif', fontSize: '1.1rem', fontWeight: 700, color: '#F0E8D6' }}>{profile.username}</div>
          </div>
          <button onClick={onClose} style={{ background: 'none', border: 'none', color: muted, fontSize: '1.25rem', cursor: 'pointer', lineHeight: 1, padding: '0.25rem' }}>✕</button>
        </div>

        {/* Tabs */}
        <div style={{ display: 'flex', borderBottom: `1px solid ${border}`, flexShrink: 0 }}>
          {TABS.map(t => (
            <button key={t.id} onClick={() => setTab(t.id)} style={{ flex: 1, padding: '0.75rem', background: 'none', border: 'none', borderBottom: tab === t.id ? `2px solid ${gold}` : '2px solid transparent', color: tab === t.id ? gold : dim, fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', letterSpacing: '0.1em', textTransform: 'uppercase' as const, cursor: 'pointer', marginBottom: '-1px', transition: 'color 0.2s' }}>
              {t.label}
            </button>
          ))}
        </div>

        {/* Body */}
        <div style={{ padding: '1.75rem 2rem', overflowY: 'auto', flex: 1 }}>

          {tab === 'profile' && (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
              <div>
                <label style={labelStyle}>Username</label>
                <input value={username} onChange={e => setUsername(e.target.value)} style={inputStyle} maxLength={20} />
                <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', color: dim, marginTop: '0.3rem', textAlign: 'right' as const }}>{username.length}/20</div>
              </div>
              <div>
                <label style={labelStyle}>Niche <span style={{ color: dim }}>(optional)</span></label>
                <input value={niche} onChange={e => setNiche(e.target.value)} style={inputStyle} maxLength={80} placeholder="e.g. Full-stack dev obsessed with algorithms" />
              </div>
              <div>
                <label style={labelStyle}>Bio <span style={{ color: dim }}>(optional)</span></label>
                <textarea value={bio} onChange={e => setBio(e.target.value)} style={{ ...inputStyle, minHeight: '80px', resize: 'vertical' as const }} maxLength={500} placeholder="Tell rivals what makes you worth defeating..." />
                <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', color: dim, marginTop: '0.3rem', textAlign: 'right' as const }}>{bio.length}/500</div>
              </div>
            </div>
          )}

          {tab === 'interests' && (
            <div>
              <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: muted, marginBottom: '1rem', letterSpacing: '0.1em' }}>Pick 3–8 interests · {interests.length}/8 selected</div>
              <div style={{ display: 'flex', flexWrap: 'wrap' as const, gap: '0.5rem' }}>
                {INTERESTS.map(i => {
                  const active = interests.includes(i);
                  return (
                    <button key={i} onClick={() => toggleInterest(i)} style={{ padding: '0.35rem 0.85rem', background: active ? gold : 'transparent', border: `1px solid ${active ? gold : border}`, color: active ? bg : muted, fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', cursor: 'pointer', transition: 'all 0.15s', letterSpacing: '0.05em' }}>
                      {i}
                    </button>
                  );
                })}
              </div>
            </div>
          )}

          {tab === 'level' && (
            <div>
              <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: muted, marginBottom: '1rem', letterSpacing: '0.1em' }}>Used for rival matching — not your displayed rank.</div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.75rem' }}>
                {LEVELS.map(lv => {
                  const active = skillTier === lv.title;
                  return (
                    <button key={lv.title} onClick={() => setSkillTier(lv.title)} style={{ padding: '1.25rem', background: active ? 'rgba(201,168,76,0.08)' : 'transparent', border: `1px solid ${active ? gold : border}`, cursor: 'pointer', textAlign: 'left' as const, transition: 'all 0.15s' }}>
                      <div style={{ fontSize: '1.25rem', marginBottom: '0.4rem' }}>{lv.icon}</div>
                      <div style={{ fontFamily: 'Cinzel, serif', fontSize: '0.9rem', fontWeight: 600, color: active ? gold : '#F0E8D6', marginBottom: '0.25rem' }}>{lv.title}</div>
                      <div style={{ fontFamily: 'DM Sans, sans-serif', fontSize: '0.75rem', color: dim, fontWeight: 300 }}>{lv.desc}</div>
                    </button>
                  );
                })}
              </div>
            </div>
          )}

          {tab === 'goals' && (
            <div>
              <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', color: muted, marginBottom: '1rem', letterSpacing: '0.1em' }}>Choose up to 3 goals · {goals.length}/3 selected</div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.75rem' }}>
                {GOALS.map(gl => {
                  const active = goals.includes(gl.title);
                  return (
                    <button key={gl.title} onClick={() => toggleGoal(gl.title)} style={{ display: 'flex', alignItems: 'flex-start', gap: '0.75rem', padding: '0.85rem', background: active ? 'rgba(201,168,76,0.08)' : 'transparent', border: `1px solid ${active ? gold : border}`, cursor: 'pointer', textAlign: 'left' as const, transition: 'all 0.15s' }}>
                      <div style={{ width: '28px', height: '28px', borderRadius: '6px', flexShrink: 0, background: active ? gold : 'rgba(201,168,76,0.1)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '0.85rem', color: active ? bg : muted }}>
                        {gl.icon}
                      </div>
                      <div>
                        <div style={{ fontFamily: 'DM Sans, sans-serif', fontSize: '0.8rem', fontWeight: 500, color: active ? gold : '#F0E8D6', marginBottom: '0.2rem' }}>{gl.title}</div>
                        <div style={{ fontFamily: 'DM Sans, sans-serif', fontSize: '0.72rem', color: dim, fontWeight: 300 }}>{gl.sub}</div>
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div style={{ padding: '1.25rem 2rem', borderTop: `1px solid ${border}`, display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexShrink: 0 }}>
          <div style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', color: '#E05C2A', minHeight: '1rem' }}>{error ?? ''}</div>
          <div style={{ display: 'flex', gap: '0.75rem' }}>
            <button onClick={onClose} style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', letterSpacing: '0.1em', textTransform: 'uppercase' as const, background: 'transparent', border: `1px solid ${border}`, color: dim, padding: '0.6rem 1.25rem', cursor: 'pointer' }}>Cancel</button>
            <button onClick={handleSave} disabled={saving} style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', letterSpacing: '0.1em', textTransform: 'uppercase' as const, background: saving ? dim : gold, color: bg, border: 'none', padding: '0.6rem 1.5rem', cursor: saving ? 'not-allowed' : 'pointer', fontWeight: 500, transition: 'background 0.2s' }}>
              {saving ? 'Saving…' : 'Save Changes'}
            </button>
          </div>
        </div>
      </div>
    </>
  );
}