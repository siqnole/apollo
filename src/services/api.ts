import axios from 'axios';
import { FullOnboardingData } from './onboardingValidation';

const api = axios.create({
  baseURL:         process.env.REACT_APP_API_URL ?? 'http://localhost:3001',
  withCredentials: true,
});

api.interceptors.response.use(
  (res: any) => res,
  (err: any) => {
    if (err.response?.status === 401 && !window.location.pathname.startsWith('/login')) {
      window.location.href = '/login';
    }
    return Promise.reject(err);
  }
);

const stored = localStorage.getItem('apollo_token');
if (stored) {
  api.defaults.headers.common['Authorization'] = `Bearer ${stored}`;
}

function storeToken(token: string) {
  localStorage.setItem('apollo_token', token);
  api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
}

// Always attach admin key if present (only has effect on /api/admin/* routes)
if (process.env.REACT_APP_ADMIN_KEY) {
  api.defaults.headers.common['x-admin-key'] = process.env.REACT_APP_ADMIN_KEY;
}

// ─── Auth ──────────────────────────────────────────────────────────────────

export const login = async (email: string, password: string) => {
  const { data } = await api.post('/api/auth/login', { email, password });
  if (data.token) storeToken(data.token);
  return data;
};

export const logout = () => {
  localStorage.removeItem('apollo_token');
  delete api.defaults.headers.common['Authorization'];
  window.location.href = '/login';
};

// ─── Onboarding ────────────────────────────────────────────────────────────

export interface OnboardingPayload extends Omit<FullOnboardingData, 'level'> {
  skill_tier: string;
  email:      string;
  password:   string;
  socials?:   Record<string, boolean>;
}

export interface OnboardingResponse {
  user: {
    id:            string;
    username:      string;
    rank:          string;   // computed from xp (always Explorer on signup)
    xp:            number;
    matchedRivals: number;
  };
  token?: string;
}

export const submitOnboarding = async (
  payload: OnboardingPayload
): Promise<OnboardingResponse> => {
  const { data } = await api.post<OnboardingResponse>('/api/users/onboard', payload);
  if (data.token) storeToken(data.token);
  return data;
};

export const checkUsernameAvailability = async (username: string): Promise<boolean> => {
  const { data } = await api.get<{ available: boolean }>('/api/users/check-username', {
    params: { username },
  });
  return data.available;
};

// ─── User ──────────────────────────────────────────────────────────────────

export interface UserProfile {
  id:         string;
  username:   string;
  niche:      string | null;
  bio:        string | null;
  rank:       string;        // computed from xp
  skill_tier: string;        // chosen during onboarding, used for rival matching
  xp:         number;
  created_at: string;
  interests:  string[];
  goals:      string[];
  socials:    { platform: string; connected: boolean; profile_url: string | null }[];
  rivalCount: number;
}

export interface Rival {
  id:        string;
  username:  string;
  rank:      string;         // computed from xp
  skill_tier: string;
  xp:        number;
  niche:     string | null;
  interests: string[];
}

export const getMe = async (): Promise<UserProfile> => {
  const { data } = await api.get<UserProfile>('/api/users/me');
  return data;
};

export const updateXp = async (
  delta: number,
  reason?: string
): Promise<{ xp: number; rank: string; delta: number }> => {
  const { data } = await api.post('/api/users/xp', { delta, reason });
  return data;
};

export const updateMe = async (patch: {
  username?:   string;
  niche?:      string;
  bio?:        string;
  skill_tier?: string;
  interests?:  string[];
  goals?:      string[];
}): Promise<UserProfile> => {
  const { data } = await api.patch<UserProfile>('/api/users/me', patch);
  return data;
};

export const getRivals = async (): Promise<Rival[]> => {
  const { data } = await api.get<{ rivals: Rival[] }>('/api/users/rivals');
  return data.rivals;
};

// ─── Arena ─────────────────────────────────────────────────────────────────

export interface Problem {
  id:                  string;
  slug:                string;
  title:               string;
  problem_type:        'code' | 'multiple_choice' | 'fill_blank' | 'debug' | 'ordering' | 'short_answer' | 'html_css' | 'shell' | 'shell_sql' | 'sql';
  difficulty:          'Easy' | 'Medium' | 'Hard' | 'Expert';
  category:            string;
  xp_reward:           number;
  tags:                string[];
  solve_count:         number;
  solved:              boolean;
  supported_languages: string[];
}

export interface ProblemDetail extends Problem {
  description:         string;
  starter_code:        Record<string, string> | null;
  hints:               string[];
  supported_languages: string[];
  test_cases:          { id: string; input: string; expected_output: string | null; is_hidden: boolean; explanation?: string }[];
  options:             { id: string; label: string; body: string; display_order: number }[];
}

export interface SubmissionResult {
  id:           string;
  status:       'accepted' | 'wrong_answer' | 'runtime_error' | 'compile_error' | 'time_limit';
  output:       string;
  runtime_ms:   number;
  test_results: { input: string; expected: string; actual: string; passed: boolean; error?: string }[];
  xp_awarded:   number;
}

export const getProblems = async (filters?: {
  category?: string; difficulty?: string; type?: string; search?: string;
}): Promise<Problem[]> => {
  const { data } = await api.get<{ problems: Problem[] }>('/api/problems', { params: filters });
  return data.problems;
};

export const getProblem = async (slug: string): Promise<ProblemDetail> => {
  const { data } = await api.get<ProblemDetail>(`/api/problems/${slug}`);
  return data;
};

export const submitSolution = async (payload: {
  problem_slug: string;
  language?:    string;
  code?:        string;
  answer?:      string;
  hints_used?:  number;  // number of paid hints revealed (first hint is free)
}): Promise<SubmissionResult> => {
  const { data } = await api.post<SubmissionResult>('/api/submissions', payload);
  return data;
};

export const runCode = async (payload: {
  language:    string;
  code:        string;
  input?:      string;
  fn_name?:    string;
  debug_mode?: boolean;
}): Promise<{ output: string; runtime_ms: number; error: string | null; stderr: string | null }> => {
  const { data } = await api.post('/api/run', payload);
  return data;
};

export const getSubmissions = async (problem_slug?: string) => {
  const { data } = await api.get<{ submissions: any[] }>('/api/submissions', { params: problem_slug ? { problem_slug } : {} });
  return data.submissions;
};

// ─── Anti-cheat ────────────────────────────────────────────────────────────

export const submitAppeal = async (payload: {
  slug:   string;
  reason: string;
  code?:  string;  // pasted code that triggered the ban
}): Promise<void> => {
  await api.post('/api/appeals', payload);
};

export const checkAppealCleared = async (slug: string): Promise<boolean> => {
  const { data } = await api.get<{ cleared: boolean }>(`/api/appeals/check/${slug}`);
  return data.cleared;
};

// ─── Admin ─────────────────────────────────────────────────────────────────

export interface Appeal {
  id:         string;
  user_id:    string | null;
  username:   string | null;
  slug:       string;
  reason:     string;
  code:       string | null;
  status:     'pending' | 'cleared' | 'upheld';
  created_at: string;
}

export interface AdminSubmission {
  id:           string;
  user_id:      string;
  username:     string | null;
  problem_slug: string;
  problem_type: string;
  language:     string | null;
  code:         string | null;
  answer:       string | null;
  status:       string;
  output:       string | null;
  runtime_ms:   number | null;
  xp_awarded:   number;
  test_results: any[];
  created_at:   string;
}

export const getAdminAppeals = async (status?: string): Promise<Appeal[]> => {
  const { data } = await api.get<{ appeals: Appeal[] }>('/api/admin/appeals', {
    params: status ? { status } : {},
  });
  return data.appeals;
};

export const updateAppealStatus = async (
  id: string,
  status: 'cleared' | 'upheld'
): Promise<void> => {
  await api.patch(`/api/admin/appeals/${id}`, { status });
};

export const getAdminSubmissions = async (params?: {
  slug?:   string;
  status?: string;
  user?:   string;
  limit?:  number;
  offset?: number;
}): Promise<AdminSubmission[]> => {
  const { data } = await api.get<{ submissions: AdminSubmission[] }>('/api/admin/submissions', { params });
  return data.submissions;
};

// ─── Social OAuth ──────────────────────────────────────────────────────────

const OAUTH_POPUP_OPTS = 'width=600,height=700,left=200,top=100';

export const connectSocial = (platform: 'gh' | 'li' | 'tw' | 'dev' | 'google'): Promise<boolean> => {
  const platformRoutes: Record<string, string> = {
    gh:     '/auth/github',
    li:     '/auth/linkedin',
    tw:     '/auth/twitter',
    dev:    '/auth/devto',
    google: '/auth/google',
  };

  return new Promise((resolve) => {
    const url = `${process.env.REACT_APP_API_URL ?? 'http://localhost:3001'}${platformRoutes[platform]}`;
    const popup = window.open(url, `Connect ${platform}`, OAUTH_POPUP_OPTS);

    const handler = (event: MessageEvent) => {
      if (event.data?.type === 'oauth_success' && event.data?.platform === platform) {
        window.removeEventListener('message', handler);
        popup?.close();
        resolve(true);
      }
      if (event.data?.type === 'oauth_error') {
        window.removeEventListener('message', handler);
        popup?.close();
        resolve(false);
      }
    };

    window.addEventListener('message', handler);

    const checkClosed = setInterval(() => {
      if (popup?.closed) {
        clearInterval(checkClosed);
        window.removeEventListener('message', handler);
        resolve(false);
      }
    }, 500);
  });
};

export default api;