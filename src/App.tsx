import React, { useEffect, useRef, Suspense } from 'react';
import { BrowserRouter, Routes, Route, useNavigate, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCompass, faDumbbell, faBuilding, faCrown, faBullseye, faChartLine, faLink, faTrophy } from '@fortawesome/free-solid-svg-icons';
import { OnboardingFlow } from './components/onboarding/OnboardingFlow';
import Dashboard from './pages/Dashboard';
import Login from './pages/Login';
import Arena from './pages/Arena';
import AdminPanel from './pages/AdminPanel';
import NotFound from './pages/NotFound';
import TermsOfService from './pages/TermsOfService';
import PrivacyPolicy from './pages/PrivacyPolicy';
import './App.css';

// Lazy-loaded heavy components
const ArenaProblem = React.lazy(() => import('./pages/ArenaProblem'));

// Loading fallback component
function LoadingFallback() {
  return (
    <div style={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      height: '100vh',
      background: '#0A0906',
      color: '#C9A84C',
      fontSize: '1rem',
      fontFamily: 'DM Mono, monospace',
    }}>
      <div style={{ textAlign: 'center' }}>
        <div style={{ fontSize: '2rem', marginBottom: '1rem' }}>⟳</div>
        <div>Loading problem...</div>
      </div>
    </div>
  );
}

// ── Icon Mapper ──────────────────────────────────────────────────────────────
const ICON_MAP: Record<string, any> = {
  compass: faCompass,
  swords: faDumbbell,       // was faSwords
  colosseum: faBuilding,    // was faColosseum
  crown: faCrown,
  bullseye: faBullseye,
  chartLine: faChartLine,
  link: faLink,
  trophy: faTrophy,
};

function renderIcon(iconName: string): React.JSX.Element {
  return <FontAwesomeIcon icon={ICON_MAP[iconName] || faCompass} />;
}

// ── Data ─────────────────────────────────────────────────────────────────────

const queryClient = new QueryClient();

const MARQUEE_ITEMS = [
  'Algorithms', 'System Design', 'Frontend Dev', 'Backend Dev',
  'Machine Learning', 'Data Science', 'Mobile Dev', 'DevOps',
  'Security', 'Databases', 'Game Dev', 'UI/UX', 'Cloud', 'Blockchain',
];

const LEVELS = [
  {
    icon: 'compass',
    name: 'Explorer',
    xp: '0 – 499 XP',
    desc: 'You just entered the arena. Pick your rivals, find your niche, and make your first move.',
    featured: false,
  },
  {
    icon: 'swords',
    name: 'Contender',
    xp: '500 – 1999 XP',
    desc: "You've drawn blood. Rivals know your name. Now prove it wasn't luck.",
    featured: false,
  },
  {
    icon: 'colosseum',
    name: 'Gladiator',
    xp: '2000 – 4999 XP',
    desc: "The crowd watches. You've beaten the odds, crushed milestones, and earned your place.",
    featured: true,
    badge: 'Popular',
  },
  {
    icon: 'crown',
    name: 'Champion',
    xp: '5000+ XP',
    desc: 'Unmatched. Unchallenged. You are the standard others measure themselves against.',
    featured: false,
  },
];

const HOW_STEPS = [
  {
    num: '01',
    title: 'Build Your Identity',
    desc: 'Set your username, pick your niche, and define the skills you obsess over. Your profile is your challenge to the world.',
  },
  {
    num: '02',
    title: 'Find Your Rivals',
    desc: 'Apollo matches you with developers at your level who share your interests. Not enemies — worthy opponents.',
  },
  {
    num: '03',
    title: 'Compete & Climb',
    desc: 'Complete goals, earn XP, and climb through the ranks. Every milestone moves you up the leaderboard.',
  },
];

const FEATURES = [
  {
    icon: 'bullseye',
    title: 'Rival Matching',
    desc: 'Our algorithm pairs you with developers who match your skill level and interests — close enough to push you, far enough to inspire.',
  },
  {
    icon: 'chartLine',
    title: 'XP & Progression',
    desc: 'Every goal completed, every challenge won earns XP. Watch your rank climb and your rivals scramble to keep up.',
  },
  {
    icon: 'link',
    title: 'Social Integration',
    desc: 'Connect GitHub, LinkedIn, Dev.to and more. Your public work feeds your Apollo reputation automatically.',
  },
  {
    icon: 'trophy',
    title: 'Goal Tracking',
    desc: 'Set bold goals — ship a SaaS, hit 1k stars, land a new role. Apollo keeps you accountable and rivals keep you honest.',
  },
];

// ── Helpers ───────────────────────────────────────────────────────────────────

function AnimSection({
  children,
  style,
}: {
  children: React.ReactNode;
  style?: React.CSSProperties;
}) {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const el = entry.target as HTMLElement;
            el.style.opacity = '1';
            el.style.transform = 'translateY(0)';
          }
        });
      },
      { threshold: 0.1 }
    );
    const el = ref.current;
    if (el) observer.observe(el);
    return () => {
      if (el) observer.unobserve(el);
    };
  }, []);

  return (
    <div
      ref={ref}
      style={{
        opacity: 0,
        transform: 'translateY(30px)',
        transition: 'opacity 0.7s ease, transform 0.7s ease',
        ...style,
      }}
    >
      {children}
    </div>
  );
}

// ── Homepage ──────────────────────────────────────────────────────────────────

function HomePage() {
  const navigate = useNavigate();
  const isLoggedIn = !!localStorage.getItem('apollo_token');
  const goArena = () => navigate(isLoggedIn ? '/dashboard' : '/onboard');
  const doubled = [...MARQUEE_ITEMS, ...MARQUEE_ITEMS];

  return (
    <div>
      {/* Nav */}
      <nav className="nav">
        <a href="/" className="nav-logo">
          <img src="/apollo.png" alt="Apollo Logo" className="logo-img" />
        </a>
        <ul className="nav-links">
          <li><a href="#how">How it works</a></li>
          <li><a href="#levels">Levels</a></li>
          <li><a href="#features">Features</a></li>
        </ul>
        <button className="nav-cta" onClick={goArena}>{isLoggedIn ? 'Re-enter Arena' : 'Enter the Arena'}</button>
      </nav>

      {/* Hero */}
      <section className="hero">
        <div className="hero-glow" />
        <div className="hero-glow-2" />
        <div className="hero-tag">Because Iron Sharpens Iron.</div>
        <h1>
          <span className="line-dim">Find Your</span>
          <span className="line-gold">Rival.</span>
        </h1>
        <p className="hero-sub">
          Apollo matches you with developers at your level. Compete on goals,
          earn XP, and climb the ranks — or watch someone else do it first.
        </p>
        <div className="hero-actions">
          <button className="btn-primary" onClick={goArena}>
            <span>{isLoggedIn ? 'Re-enter the Arena' : 'Claim Your Arena Name'}</span>
          </button>
          <button className="btn-ghost" onClick={() => document.getElementById('how')?.scrollIntoView({ behavior: 'smooth' })}>
            See How It Works
          </button>
        </div>
        <div className="hero-stats">
          <div>
            <div className="stat-val">12k+</div>
            <div className="stat-label">Active Rivals</div>
          </div>
          <div>
            <div className="stat-val">840k</div>
            <div className="stat-label">XP Earned</div>
          </div>
          <div>
            <div className="stat-val">94%</div>
            <div className="stat-label">Match Accuracy</div>
          </div>
        </div>
      </section>

      {/* Marquee */}
      <div className="marquee-wrap">
        <div className="marquee-track">
          {doubled.map((item, i) => (
            <span key={i} className="marquee-item">{item}</span>
          ))}
        </div>
      </div>

      {/* How It Works */}
      <section className="how" id="how">
        <AnimSection>
          <div className="section-tag">The Process</div>
          <h2 className="section-title">Three steps to your <em>first rival</em></h2>
        </AnimSection>
        <AnimSection style={{ transitionDelay: '0.15s' }}>
          <div className="how-grid">
            {HOW_STEPS.map((step) => (
              <div key={step.num} className="how-card">
                <div className="how-num">{step.num}</div>
                <h3>{step.title}</h3>
                <p>{step.desc}</p>
              </div>
            ))}
          </div>
        </AnimSection>
      </section>

      {/* Levels */}
      <section className="levels" id="levels">
        <div className="levels-inner">
          <AnimSection>
            <div className="section-tag">Rank System</div>
            <h2 className="section-title">Where do you <em>stand?</em></h2>
          </AnimSection>
          <AnimSection style={{ transitionDelay: '0.15s' }}>
            <div className="levels-grid">
              {LEVELS.map((level) => (
                <div key={level.name} className={`level-card${level.featured ? ' featured' : ''}`}>
                  {level.badge && <span className="level-badge">{level.badge}</span>}
                  <div className="level-icon">{renderIcon(level.icon)} | {level.name}</div>
                  <div className="level-xp">{level.xp}</div>
                  <p className="level-desc">{level.desc}</p>
                </div>
              ))}
            </div>
          </AnimSection>
        </div>
      </section>

      {/* Features */}
      <section className="features" id="features">
        <AnimSection>
          <div className="section-tag">Platform</div>
          <h2 className="section-title">Built for the <em>obsessed</em></h2>
        </AnimSection>
        <AnimSection style={{ transitionDelay: '0.15s' }}>
          <div className="features-grid">
            {FEATURES.map((f) => (
              <div key={f.title} className="feature-card">
                <div className="feature-icon">{renderIcon(f.icon)} | {f.title}</div>
                <p>{f.desc}</p>
              </div>
            ))}
          </div>
        </AnimSection>
      </section>

      {/* CTA */}
      <section className="cta-section">
        <AnimSection>
          <h2 className="cta-title">
            Ready to<br />
            <span style={{ color: 'var(--gold)' }}>be challenged?</span>
          </h2>
          <p className="cta-sub">
            Your rival is already out there, grinding. The question is whether
            you'll meet them at the top or watch from below.
          </p>
          <button className="btn-primary" onClick={goArena}>
            <span>{isLoggedIn ? 'Re-enter the Arena' : 'Enter the Arena'}</span>
          </button>
        </AnimSection>
      </section>

      {/* Footer */}
      <footer className="footer">
        <div className="footer-logo">
          <img src="/apolloBlack.png" alt="Apollo Logo" className="logo-img-footer" />
        </div>
        <div className="footer-links">
          <a href="/tos" className="footer-link">Terms of Service</a>
          <a href="/privacy" className="footer-link">Privacy Policy</a>
        </div>
        <div className="footer-note">© 2025 Apollo — Forge your legacy</div>
      </footer>
    </div>
  );
}

// ── Root ──────────────────────────────────────────────────────────────────────

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/onboard" element={<OnboardingFlow />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/tos"         element={<TermsOfService />} />
          <Route path="/terms"       element={<Navigate to="/tos" replace />} />
          <Route path="/privacy"     element={<PrivacyPolicy />} />
          <Route path="/login" element={<Login />} />
          <Route path="/arena" element={<Arena />} />
          <Route 
            path="/arena/:slug" 
            element={
              <Suspense fallback={<LoadingFallback />}>
                <ArenaProblem />
              </Suspense>
            } 
          />
          <Route path="/admin"       element={<AdminPanel />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  );
}

export default App;