import { useState, useCallback } from 'react';
import { useMutation } from '@tanstack/react-query';
import { z } from 'zod';
import {
  OnboardingFormData,
  OnboardingErrors,
  OnboardingStep,
  SocialPlatform,
  ExperienceLevel,
} from '../types/onboarding';
import { stepSchemas } from '../services/onboardingValidation';
import { submitOnboarding, connectSocial } from '../services/api';

const INITIAL_STATE: OnboardingFormData = {
  email:     '',
  password:  '',
  username:  '',
  niche:     '',
  bio:       '',
  interests: [],
  level:     '',
  goals:     [],
  socials:   {},
};

export const useOnboarding = () => {
  const [step, setStep]     = useState<OnboardingStep>(0);
  const [form, setForm]     = useState<OnboardingFormData>(INITIAL_STATE);
  const [errors, setErrors] = useState<OnboardingErrors>({});
  const [isDone, setIsDone] = useState(false);

  const mutation = useMutation({
    mutationFn: submitOnboarding,
    onSuccess:  () => setIsDone(true),
  });

  const setEmail    = useCallback((v: string) => setForm(f => ({ ...f, email:    v })), []);
  const setPassword = useCallback((v: string) => setForm(f => ({ ...f, password: v })), []);
  const setUsername = useCallback((v: string) => setForm(f => ({ ...f, username: v })), []);
  const setNiche    = useCallback((v: string) => setForm(f => ({ ...f, niche:    v })), []);
  const setBio      = useCallback((v: string) => setForm(f => ({ ...f, bio:      v })), []);

  const toggleInterest = useCallback((interest: string) => {
    setForm(f => {
      const has = f.interests.includes(interest);
      if (has) return { ...f, interests: f.interests.filter(i => i !== interest) };
      if (f.interests.length >= 8) return f;
      return { ...f, interests: [...f.interests, interest] };
    });
  }, []);

  const setLevel = useCallback((level: ExperienceLevel) =>
    setForm(f => ({ ...f, level })), []);

  const toggleGoal = useCallback((goal: string) => {
    setForm(f => {
      const has = f.goals.includes(goal);
      if (has) return { ...f, goals: f.goals.filter(g => g !== goal) };
      if (f.goals.length >= 3) return f;
      return { ...f, goals: [...f.goals, goal] };
    });
  }, []);

  const connectSocialPlatform = useCallback(async (platform: SocialPlatform) => {
    const success = await connectSocial(platform);
    if (success) {
      setForm(f => ({
        ...f,
        socials: { ...f.socials, [platform]: { platform, connected: true } },
      }));
    }
    return success;
  }, []);

  const validate = useCallback((): boolean => {
    const schema = stepSchemas[step];
    const result = (schema as z.ZodTypeAny).safeParse(form);
    if (result.success) { setErrors({}); return true; }
    const fieldErrors: OnboardingErrors = {};
    result.error.issues.forEach((e: z.ZodIssue) => {
      const field = e.path[0] as keyof OnboardingErrors;
      if (field) fieldErrors[field] = e.message;
    });
    setErrors(fieldErrors);
    return false;
  }, [step, form]);

  const LAST_STEP = 6 as OnboardingStep;

  const goNext = useCallback(async () => {
    if (!validate()) return;
    if (step === LAST_STEP) {
      await mutation.mutateAsync({
        email:     form.email,
        password:  form.password,
        username:  form.username,
        niche:     form.niche,
        bio:       form.bio,
        interests: form.interests as any,
        skill_tier: form.level as ExperienceLevel,
        goals:     form.goals,
        socials:   Object.fromEntries(
          Object.entries(form.socials).map(([k, v]) => [k, !!v?.connected])
        ),
      });
      return;
    }
    setStep(s => (s + 1) as OnboardingStep);
    setErrors({});
  }, [step, form, validate, mutation]);

  const goBack = useCallback(() => {
    if (step > 0) { setStep(s => (s - 1) as OnboardingStep); setErrors({}); }
  }, [step]);

  return {
    step, form, errors, isDone,
    isSubmitting: mutation.isPending,
    submitError:  mutation.error,
    setEmail, setPassword,
    setUsername, setNiche, setBio,
    toggleInterest, setLevel, toggleGoal,
    connectSocialPlatform,
    goNext, goBack,
  };
};