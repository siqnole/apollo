import React from 'react';
import { useNavigate } from 'react-router-dom';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faHome, faDumbbell } from '@fortawesome/free-solid-svg-icons';

export default function NotFound() {
  const navigate = useNavigate();

  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#0A0906', color: '#F0E8D6' }}>
      <div style={{ textAlign: 'center', padding: '2rem' }}>
        <div style={{ fontSize: '8rem', marginBottom: '1rem', opacity: 0.7 }}>
          <FontAwesomeIcon icon={faDumbbell} />
        </div>
        
        <h1 style={{ fontFamily: 'Cinzel, serif', fontSize: 'clamp(2rem, 5vw, 4rem)', fontWeight: 900, margin: '0 0 1rem 0', color: '#C9A84C' }}>
          404
        </h1>
        
        <p style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.85rem', letterSpacing: '0.15em', textTransform: 'uppercase' as const, color: '#7A6230', marginBottom: '1rem' }}>
          Out of Bounds
        </p>
        
        <p style={{ fontFamily: 'Cinzel, serif', fontSize: '1.5rem', fontWeight: 600, color: '#F0E8D6', marginBottom: '0.5rem' }}>
          Looks like you've gone out of bounds.
        </p>
        
        <p style={{ fontFamily: 'DM Mono, monospace', fontSize: '0.95rem', color: '#8A7D65', maxWidth: '400px', margin: '0 auto 2rem' }}>
          The page you're looking for doesn't exist. It might've been knocked out of the ring, or maybe you took a wrong turn.
        </p>
        
        <div style={{ display: 'flex', gap: '1rem', justifyContent: 'center', flexWrap: 'wrap' as const }}>
          <button
            onClick={() => navigate('/')}
            style={{
              fontFamily: 'DM Mono, monospace',
              fontSize: '0.75rem',
              letterSpacing: '0.15em',
              textTransform: 'uppercase' as const,
              padding: '0.75rem 1.5rem',
              background: 'transparent',
              border: '2px solid #C9A84C',
              color: '#C9A84C',
              cursor: 'pointer',
              transition: 'all 0.3s',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = '#C9A84C';
              e.currentTarget.style.color = '#0A0906';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = 'transparent';
              e.currentTarget.style.color = '#C9A84C';
            }}
          >
            <FontAwesomeIcon icon={faHome} /> Back to Ring
          </button>
          
          <button
            onClick={() => navigate(-1)}
            style={{
              fontFamily: 'DM Mono, monospace',
              fontSize: '0.75rem',
              letterSpacing: '0.15em',
              textTransform: 'uppercase' as const,
              padding: '0.75rem 1.5rem',
              background: 'transparent',
              border: '1px solid rgba(201,168,76,0.3)',
              color: '#7A6230',
              cursor: 'pointer',
              transition: 'all 0.3s',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.borderColor = 'rgba(201,168,76,0.6)';
              e.currentTarget.style.color = '#C9A84C';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.borderColor = 'rgba(201,168,76,0.3)';
              e.currentTarget.style.color = '#7A6230';
            }}
          >
            Go Back
          </button>
        </div>
      </div>
    </div>
  );
}
