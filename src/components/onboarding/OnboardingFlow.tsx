import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { StepsBar } from './StepsBar';
import { StepCredentials } from './StepCredentials';
import { StepProfile } from './StepProfile';
import {
  StepInterests,
  StepLevel,
  StepGoals,
  StepSocials,
  StepReview,
} from './OnboardingSteps';
import { OnboardingSuccess } from './OnboardingSuccess';
import { Button } from '@/components/ui/button';
import { useOnboarding } from '../../hooks/useOnboarding';

export const OnboardingFlow: React.FC = () => {
  const navigate = useNavigate();
  const {
    step, form, errors, isDone, isSubmitting, submitError,
    setEmail, setPassword,
    setUsername, setNiche, setBio,
    toggleInterest, setLevel, toggleGoal,
    connectSocialPlatform,
    goNext, goBack,
  } = useOnboarding();

  // Redirect to dashboard if already logged in
  useEffect(() => {
    const token = localStorage.getItem('apollo_token');
    if (token) {
      navigate('/dashboard');
    }
  }, [navigate]);

  const LAST_STEP = 6;

  const renderStep = () => {
    switch (step) {
      case 0: return (
        <StepCredentials
          form={form} errors={errors}
          onEmailChange={setEmail}
          onPasswordChange={setPassword}
        />
      );
      case 1: return (
        <StepProfile
          form={form} errors={errors}
          onUsernameChange={setUsername}
          onNicheChange={setNiche}
          onBioChange={setBio}
        />
      );
      case 2: return <StepInterests form={form} errors={errors} onToggle={toggleInterest} />;
      case 3: return <StepLevel    form={form} errors={errors} onSelect={setLevel} />;
      case 4: return <StepGoals   form={form} errors={errors} onToggle={toggleGoal} />;
      case 5: return <StepSocials form={form} onConnect={connectSocialPlatform} />;
      case 6: return <StepReview  form={form} />;
      default: return null;
    }
  };

  return (
    <div className="min-h-screen bg-background flex items-center justify-center px-4 py-12">
      <div className="w-full max-w-lg">

        <div className="flex items-center gap-2 mb-10">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
            <path
              d="M12 2C10 4 9 6 10 8C8 7 7 5 8 3C6 5 6 8 8 10C6 10 5 8 5 6C4 9 5 12 8 13L7 22H17L16 13C19 12 20 9 19 6C19 8 18 10 16 10C18 8 18 5 16 3C17 5 16 7 14 8C15 6 14 4 12 2Z"
              fill="#C8922A"
            />
          </svg>
          <span className="font-serif text-xl font-semibold">
            Apol<span className="text-amber-500">lo</span>
          </span>
        </div>

        {!isDone && <StepsBar currentStep={step} />}

        <div className="bg-card border border-border rounded-2xl p-7 mb-5 animate-in fade-in slide-in-from-bottom-2 duration-300">
          {isDone ? <OnboardingSuccess form={form} /> : renderStep()}
        </div>

        {!isDone && (
          <div className="flex items-center justify-between">
            <Button
              type="button"
              variant="outline"
              onClick={goBack}
              disabled={step === 0}
              className="min-w-[90px]"
            >
              ← Back
            </Button>

            <span className="text-xs text-muted-foreground">
              {step + 1} of {LAST_STEP + 1}
            </span>

            <Button
              type="button"
              onClick={goNext}
              disabled={isSubmitting}
              className="bg-amber-500 hover:bg-amber-600 text-white min-w-[120px]"
            >
              {isSubmitting ? 'Launching…' : step === LAST_STEP ? 'Launch →' : 'Continue →'}
            </Button>
          </div>
        )}

        {submitError && (
          <p className="text-xs text-destructive text-center mt-3">
            {(submitError as any)?.response?.data?.error ?? 'Something went wrong — please try again.'}
          </p>
        )}
      </div>
    </div>
  );
};