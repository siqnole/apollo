import React from 'react';
import { cn } from '@/lib/utils';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  OnboardingFormData,
  OnboardingErrors,
  INTERESTS,
  LEVELS,
  GOALS,
  SOCIAL_PLATFORMS,
  SocialPlatform,
} from '../../types/onboarding';

// ─── Step 1: Interests ───────────────────────────────────────────────────────

interface StepInterestsProps {
  form: OnboardingFormData;
  errors: OnboardingErrors;
  onToggle: (interest: string) => void;
}

export const StepInterests: React.FC<StepInterestsProps> = ({ form, errors, onToggle }) => (
  <div className="space-y-5">
    <div>
      <h2 className="font-serif text-xl font-semibold">What's your arena?</h2>
      <p className="text-sm text-muted-foreground mt-1">
        Pick 3–8 topics to compete in. We'll use these to find your perfect rivals.
      </p>
    </div>

    <div className="flex flex-wrap gap-2">
      {INTERESTS.map(interest => (
        <button
          key={interest}
          type="button"
          onClick={() => onToggle(interest)}
          className={cn(
            'px-3 py-1.5 rounded-full border text-sm transition-all duration-150',
            form.interests.includes(interest)
              ? 'bg-amber-500 border-amber-500 text-white'
              : 'border-border text-muted-foreground hover:border-amber-400 bg-background',
          )}
        >
          {interest}
        </button>
      ))}
    </div>

    <div className="flex justify-between items-center">
      {errors.interests
        ? <p className="text-xs text-destructive">{errors.interests}</p>
        : <span />
      }
      <span className="text-xs text-muted-foreground">{form.interests.length}/8 selected</span>
    </div>
  </div>
);

// ─── Step 2: Level ───────────────────────────────────────────────────────────

interface StepLevelProps {
  form: OnboardingFormData;
  errors: OnboardingErrors;
  onSelect: (level: any) => void;
}

export const StepLevel: React.FC<StepLevelProps> = ({ form, errors, onSelect }) => (
  <div className="space-y-5">
    <div>
      <h2 className="font-serif text-xl font-semibold">Your current level</h2>
      <p className="text-sm text-muted-foreground mt-1">
        We match rivals by skill — be honest, you'll earn more respect beating your true peer.
      </p>
    </div>

    <div className="grid grid-cols-2 gap-3">
      {LEVELS.map(lv => (
        <button
          key={lv.title}
          type="button"
          onClick={() => onSelect(lv.title)}
          className={cn(
            'p-4 rounded-xl border text-left transition-all duration-150 hover:border-amber-400',
            form.level === lv.title
              ? 'border-amber-500 bg-amber-50 dark:bg-amber-950/20'
              : 'border-border bg-secondary',
          )}
        >
          <div className="text-lg mb-1">{lv.icon}</div>
          <div className={cn(
            'text-sm font-medium',
            form.level === lv.title ? 'text-amber-600' : 'text-foreground',
          )}>
            {lv.title}
          </div>
          <div className="text-xs text-muted-foreground mt-0.5">{lv.desc}</div>
        </button>
      ))}
    </div>

    {errors.level && <p className="text-xs text-destructive">{errors.level}</p>}
  </div>
);

// ─── Step 3: Goals ───────────────────────────────────────────────────────────

interface StepGoalsProps {
  form: OnboardingFormData;
  errors: OnboardingErrors;
  onToggle: (goal: string) => void;
}

export const StepGoals: React.FC<StepGoalsProps> = ({ form, errors, onToggle }) => (
  <div className="space-y-5">
    <div>
      <h2 className="font-serif text-xl font-semibold">What drives you?</h2>
      <p className="text-sm text-muted-foreground mt-1">
        Choose up to 3 goals — Apollo tailors your challenges and rivals accordingly.
      </p>
    </div>

    <div className="grid grid-cols-2 gap-3">
      {GOALS.map(gl => (
        <button
          key={gl.title}
          type="button"
          onClick={() => onToggle(gl.title)}
          className={cn(
            'flex items-start gap-3 p-3 rounded-xl border text-left transition-all duration-150 hover:border-amber-400',
            form.goals.includes(gl.title)
              ? 'border-amber-500'
              : 'border-border bg-secondary',
          )}
        >
          <div className={cn(
            'w-7 h-7 rounded-lg flex items-center justify-center text-sm flex-shrink-0',
            form.goals.includes(gl.title) ? 'bg-amber-500 text-white' : 'bg-border',
          )}>
            {gl.icon}
          </div>
          <div>
            <div className="text-xs font-medium text-foreground">{gl.title}</div>
            <div className="text-xs text-muted-foreground mt-0.5">{gl.sub}</div>
          </div>
        </button>
      ))}
    </div>

    <div className="flex justify-between items-center">
      {errors.goals
        ? <p className="text-xs text-destructive">{errors.goals}</p>
        : <span />
      }
      <span className="text-xs text-muted-foreground">{form.goals.length}/3 selected</span>
    </div>
  </div>
);

// ─── Step 4: Socials ─────────────────────────────────────────────────────────

interface StepSocialsProps {
  form: OnboardingFormData;
  onConnect: (platform: SocialPlatform) => Promise<boolean>;
}

export const StepSocials: React.FC<StepSocialsProps> = ({ form, onConnect }) => (
  <div className="space-y-5">
    <div>
      <h2 className="font-serif text-xl font-semibold">Connect your arsenal</h2>
      <p className="text-sm text-muted-foreground mt-1">
        Optional — rivals who connect accounts get verified badges and higher match quality.
      </p>
    </div>

    <div className="space-y-2">
      {SOCIAL_PLATFORMS.map(sc => {
        const isConnected = !!form.socials[sc.key]?.connected;
        return (
          <div
            key={sc.key}
            className="flex items-center gap-3 px-4 py-3 rounded-xl border border-border bg-secondary"
          >
            <div
              className="w-8 h-8 rounded-lg flex items-center justify-center text-white text-sm font-medium flex-shrink-0"
              style={{ background: sc.color }}
            >
              {sc.name[0]}
            </div>
            <span className="text-sm font-medium flex-1">{sc.name}</span>
            {isConnected ? (
              <Badge variant="outline" className="text-xs text-muted-foreground">
                Connected ✓
              </Badge>
            ) : (
              <Button
                type="button"
                variant="outline"
                size="sm"
                className="text-xs border-amber-400 text-amber-600 hover:bg-amber-500 hover:text-white h-7"
                onClick={() => onConnect(sc.key)}
              >
                Connect
              </Button>
            )}
          </div>
        );
      })}
    </div>
  </div>
);

// ─── Step 5: Review ──────────────────────────────────────────────────────────

interface StepReviewProps {
  form: OnboardingFormData;
}

const ReviewRow = ({ label, children }: { label: string; children: React.ReactNode }) => (
  <div className="flex justify-between items-start py-2.5 border-b border-border last:border-0">
    <span className="text-sm text-muted-foreground w-24 flex-shrink-0">{label}</span>
    <div className="text-sm font-medium text-right flex-1">{children}</div>
  </div>
);

export const StepReview: React.FC<StepReviewProps> = ({ form }) => {
  const connectedSocials = Object.entries(form.socials)
    .filter(([, v]) => v?.connected)
    .map(([k]) => k.toUpperCase());

  return (
    <div className="space-y-5">
      <div>
        <h2 className="font-serif text-xl font-semibold">Ready to enter the arena?</h2>
        <p className="text-sm text-muted-foreground mt-1">
          Review your challenger profile before we find your first rivals.
        </p>
      </div>

      <div className="rounded-xl border border-border bg-secondary px-4">
        <ReviewRow label="Username">{form.username || '—'}</ReviewRow>
        <ReviewRow label="Niche">{form.niche || '—'}</ReviewRow>
        <ReviewRow label="Level">{form.level || '—'}</ReviewRow>
        <ReviewRow label="Interests">
          <div className="flex flex-wrap gap-1 justify-end">
            {form.interests.length
              ? form.interests.map(i => (
                  <span key={i} className="text-xs px-2 py-0.5 rounded-full bg-background border border-border text-muted-foreground">
                    {i}
                  </span>
                ))
              : '—'
            }
          </div>
        </ReviewRow>
        <ReviewRow label="Goals">{form.goals.join(', ') || '—'}</ReviewRow>
        <ReviewRow label="Socials">
          {connectedSocials.length ? connectedSocials.join(', ') : 'None connected'}
        </ReviewRow>
      </div>
    </div>
  );
};
