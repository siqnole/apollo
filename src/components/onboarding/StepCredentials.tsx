import React, { useState } from 'react';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { OnboardingFormData, OnboardingErrors } from '../../types/onboarding';

interface StepCredentialsProps {
  form:            OnboardingFormData;
  errors:          OnboardingErrors;
  onEmailChange:   (v: string) => void;
  onPasswordChange:(v: string) => void;
}

export const StepCredentials: React.FC<StepCredentialsProps> = ({
  form, errors, onEmailChange, onPasswordChange,
}) => {
  const [showPw, setShowPw] = useState(false);

  return (
    <div className="space-y-5">
      <div>
        <h2 className="font-serif text-xl font-semibold text-foreground">Create your account</h2>
        <p className="text-sm text-muted-foreground mt-1">
          Your credentials for logging back in. No one else sees these.
        </p>
      </div>

      <div className="space-y-1">
        <Label htmlFor="email">Email</Label>
        <Input
          id="email"
          type="email"
          placeholder="you@example.com"
          value={form.email}
          onChange={(e: React.ChangeEvent<HTMLInputElement>) => onEmailChange(e.target.value)}
          className={errors.email ? 'border-destructive' : ''}
          autoComplete="email"
        />
        {errors.email && <p className="text-xs text-destructive">{errors.email}</p>}
      </div>

      <div className="space-y-1">
        <Label htmlFor="password">Password</Label>
        <div className="relative">
          <Input
            id="password"
            type={showPw ? 'text' : 'password'}
            placeholder="At least 8 characters"
            value={form.password}
            onChange={(e: React.ChangeEvent<HTMLInputElement>) => onPasswordChange(e.target.value)}
            className={errors.password ? 'border-destructive pr-12' : 'pr-12'}
            autoComplete="new-password"
          />
          <button
            type="button"
            onClick={() => setShowPw(v => !v)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground text-xs hover:text-foreground transition-colors"
            tabIndex={-1}
          >
            {showPw ? 'hide' : 'show'}
          </button>
        </div>
        {errors.password && <p className="text-xs text-destructive">{errors.password}</p>}
        <p className="text-xs text-muted-foreground">Minimum 8 characters</p>
      </div>

      <p className="text-xs text-muted-foreground pt-2 border-t border-border">
        Already have an account?{' '}
        <a href="/login" className="text-amber-500 hover:text-amber-400 transition-colors">
          Sign in here
        </a>
      </p>
    </div>
  );
};