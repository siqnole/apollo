import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { login } from '../services/api';

type Mode = 'login' | 'register';

export default function Login() {
  const navigate = useNavigate();
  const [mode, setMode]       = useState<Mode>('login');
  const [email, setEmail]     = useState('');
  const [password, setPass]   = useState('');
  const [showPw, setShowPw]   = useState(false);
  const [error, setError]     = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleSubmit = async () => {
    setError(null);
    if (!email || !password) { setError('Email and password are required'); return; }
    if (mode === 'register') { navigate('/onboard'); return; }

    setLoading(true);
    try {
      await login(email, password);
      navigate('/dashboard');
    } catch (err: any) {
      setError(err?.response?.data?.error ?? 'Something went wrong');
    } finally {
      setLoading(false);
    }
  };

  const gold   = '#C9A84C';
  const muted  = '#8A7D65';
  const dim    = '#4A4236';
  const border = 'rgba(201,168,76,0.18)';

  return (
    <div style={{ minHeight: '100vh', background: '#0A0906', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '2rem' }}>

      {/* Glow */}
      <div style={{ position: 'fixed', top: '30%', left: '50%', transform: 'translateX(-50%)', width: '600px', height: '400px', background: 'radial-gradient(ellipse, rgba(201,168,76,0.08) 0%, transparent 70%)', pointerEvents: 'none' }} />

      <div style={{ width: '100%', maxWidth: '420px', position: 'relative', zIndex: 1 }}>

        {/* Logo */}
        <a href="/" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '2.5rem', textDecoration: 'none' }}>
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
            <path d="M12 2C10 4 9 6 10 8C8 7 7 5 8 3C6 5 6 8 8 10C6 10 5 8 5 6C4 9 5 12 8 13L7 22H17L16 13C19 12 20 9 19 6C19 8 18 10 16 10C18 8 18 5 16 3C17 5 16 7 14 8C15 6 14 4 12 2Z" fill="#C8922A" />
          </svg>
          <span style={{ fontFamily: 'Cinzel, serif', fontSize: '1.2rem', fontWeight: 700, color: gold, letterSpacing: '0.1em' }}>
            APOLLO<span style={{ color: muted, fontWeight: 400 }}>.gg</span>
          </span>
        </a>

        {/* Card */}
        <div style={{ border: `1px solid ${border}`, background: '#1C1812', padding: '2.5rem' }}>

          {/* Tabs */}
          <div style={{ display: 'flex', marginBottom: '2rem', borderBottom: `1px solid ${border}` }}>
            {(['login', 'register'] as Mode[]).map(m => (
              <button
                key={m}
                onClick={() => { setMode(m); setError(null); }}
                style={{
                  flex: 1, padding: '0.75rem', background: 'transparent', border: 'none',
                  borderBottom: mode === m ? `2px solid ${gold}` : '2px solid transparent',
                  color: mode === m ? gold : dim,
                  fontFamily: 'DM Mono, monospace', fontSize: '0.7rem',
                  letterSpacing: '0.15em', textTransform: 'uppercase', cursor: 'pointer',
                  transition: 'color 0.2s',
                  marginBottom: '-1px',
                }}
              >
                {m === 'login' ? 'Sign In' : 'Register'}
              </button>
            ))}
          </div>

          {mode === 'register' ? (
            <div style={{ textAlign: 'center', padding: '1rem 0' }}>
              <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>⚔️</div>
              <p style={{ fontFamily: 'Cinzel, serif', fontSize: '1rem', color: '#F0E8D6', marginBottom: '0.5rem' }}>
                Ready to enter the arena?
              </p>
              <p style={{ fontSize: '0.85rem', color: muted, fontWeight: 300, marginBottom: '1.5rem', lineHeight: 1.6 }}>
                New challengers set up their full profile during onboarding.
              </p>
              <button
                onClick={() => navigate('/onboard')}
                style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.75rem', letterSpacing: '0.1em', textTransform: 'uppercase', background: gold, color: '#0A0906', border: 'none', padding: '0.85rem 2rem', cursor: 'pointer', width: '100%', fontWeight: 500 }}
              >
                Start Onboarding →
              </button>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>

              {/* Email */}
              <div>
                <label style={{ display: 'block', fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', letterSpacing: '0.15em', textTransform: 'uppercase', color: muted, marginBottom: '0.5rem' }}>
                  Email
                </label>
                <input
                  type="email"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  onKeyDown={e => e.key === 'Enter' && handleSubmit()}
                  placeholder="you@example.com"
                  style={{ width: '100%', background: 'transparent', border: `1px solid ${border}`, color: '#F0E8D6', padding: '0.65rem 0.85rem', fontFamily: 'DM Sans, sans-serif', fontSize: '0.9rem', outline: 'none', boxSizing: 'border-box' }}
                  autoComplete="email"
                />
              </div>

              {/* Password */}
              <div>
                <label style={{ display: 'block', fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', letterSpacing: '0.15em', textTransform: 'uppercase', color: muted, marginBottom: '0.5rem' }}>
                  Password
                </label>
                <div style={{ position: 'relative' }}>
                  <input
                    type={showPw ? 'text' : 'password'}
                    value={password}
                    onChange={e => setPass(e.target.value)}
                    onKeyDown={e => e.key === 'Enter' && handleSubmit()}
                    placeholder="Your password"
                    style={{ width: '100%', background: 'transparent', border: `1px solid ${border}`, color: '#F0E8D6', padding: '0.65rem 3rem 0.65rem 0.85rem', fontFamily: 'DM Sans, sans-serif', fontSize: '0.9rem', outline: 'none', boxSizing: 'border-box' }}
                    autoComplete="current-password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPw(v => !v)}
                    style={{ position: 'absolute', right: '0.75rem', top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', color: dim, fontFamily: 'DM Mono, monospace', fontSize: '0.65rem', cursor: 'pointer' }}
                  >
                    {showPw ? 'hide' : 'show'}
                  </button>
                </div>
              </div>

              {/* Error */}
              {error && (
                <p style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.7rem', color: '#E05C2A', letterSpacing: '0.05em' }}>
                  {error}
                </p>
              )}

              {/* Submit */}
              <button
                onClick={handleSubmit}
                disabled={loading}
                style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.75rem', letterSpacing: '0.1em', textTransform: 'uppercase', background: loading ? dim : gold, color: '#0A0906', border: 'none', padding: '0.85rem', cursor: loading ? 'not-allowed' : 'pointer', fontWeight: 500, transition: 'background 0.2s', marginTop: '0.5rem' }}
              >
                {loading ? 'Signing in…' : 'Enter the Arena →'}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}