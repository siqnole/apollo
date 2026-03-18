export type ExperienceLevel = 'Explorer' | 'Contender' | 'Gladiator' | 'Champion';

export type SocialPlatform = 'gh' | 'li' | 'tw' | 'dev' | 'google';

export interface SocialConnection {
  platform:     SocialPlatform;
  connected:    boolean;
  profileUrl?:  string;
  accessToken?: string;
}

export interface OnboardingFormData {
  email:     string;
  password:  string;
  username:  string;
  niche:     string;
  bio:       string;
  interests: string[];
  level:     ExperienceLevel | '';
  goals:     string[];
  socials:   Partial<Record<SocialPlatform, SocialConnection>>;
}

export interface OnboardingErrors {
  email?:     string;
  password?:  string;
  username?:  string;
  interests?: string;
  level?:     string;
  goals?:     string;
}

export type OnboardingStep = 0 | 1 | 2 | 3 | 4 | 5 | 6;

export const STEP_LABELS = [
  'Account', 'Profile', 'Interests', 'Level', 'Goals', 'Socials', 'Review',
] as const;

export const INTERESTS = [
  'Algorithms', 'System Design', 'Frontend Dev', 'Backend Dev',
  'Machine Learning', 'Data Science', 'Mobile Dev', 'DevOps',
  'Security', 'Databases', 'Game Dev', 'UI/UX', 'Cloud', 'Blockchain', 'Open Source',
  'Physics', 'Chemistry', 'Calculus', 'Linear Algebra', 'Differential Equations',
] as const;

export const NICHE_SUGGESTIONS = [
  'Full-stack developer',
  'Data scientist & ML engineer',
  'Physics & mechanics enthusiast',
  'Chemistry explorer',
  'Math scholar - Calculus focused',
  'STEM polymath',
  'Algorithm competitive programmer',
  'DevOps & cloud architect',
  'Frontend UI/UX specialist',
  'Game developer',
  'Blockchain & Web3 builder',
  'Mobile app developer',
] as const;

export const LEVELS: { title: ExperienceLevel; icon: string; desc: string }[] = [
  { title: 'Explorer',  icon: '◎', desc: 'New to competitive learning' },
  { title: 'Contender', icon: '◑', desc: 'Some experience, hungry to grow' },
  { title: 'Gladiator', icon: '●', desc: 'Skilled & battle-tested' },
  { title: 'Champion',  icon: '★', desc: 'Elite — here to dominate' },
];

export const GOALS: { title: string; icon: string; sub: string }[] = [
  { title: 'Sharpen skills fast', icon: '⚡', sub: 'Daily focused challenges' },
  { title: 'Climb the ranks',     icon: '▲', sub: 'Competitive leaderboard' },
  { title: 'Find my rival',       icon: '◈', sub: 'Long-term nemesis matchup' },
  { title: 'Teach & mentor',      icon: '◻', sub: 'Challenge those below me' },
  { title: 'Track progress',      icon: '◆', sub: 'Data-driven growth' },
  { title: 'Build in public',     icon: '⊕', sub: 'Earn rep & recognition' },
];

export const SOCIAL_PLATFORMS: { key: SocialPlatform; name: string; color: string }[] = [
  { key: 'google', name: 'Google',      color: '#4285F4' },
  { key: 'gh',     name: 'GitHub',      color: '#24292e' },
  { key: 'li',     name: 'LinkedIn',    color: '#0A66C2' },
  { key: 'tw',     name: 'Twitter / X', color: '#1DA1F2' },
  { key: 'dev',    name: 'Dev.to',      color: '#0a0a0a' },
];