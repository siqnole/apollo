import { z } from 'zod';
import { INTERESTS } from '../types/onboarding';

const LEVELS = ['Explorer', 'Contender', 'Gladiator', 'Champion'] as const;

export const step0Schema = z.object({
  email: z
    .string()
    .min(1, 'Email is required')
    .regex(/^[^\s@]+@[^\s@]+\.[^\s@]+$/, 'Enter a valid email address'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters'),
});

export const step1Schema = z.object({
  username: z
    .string()
    .min(3, 'Username must be at least 3 characters')
    .max(20, 'Username must be 20 characters or less')
    .regex(/^[a-zA-Z0-9_]+$/, 'Only letters, numbers, and underscores allowed'),
  niche: z.string().max(80).optional(),
  bio:   z.string().max(500).optional(),
});

export const step2Schema = z.object({
  interests: z
    .array(
      z.string().refine(
        (val) => (INTERESTS as readonly string[]).includes(val),
        { message: 'Invalid interest' }
      )
    )
    .min(3, 'Pick at least 3 interests to find compatible rivals')
    .max(8, 'Maximum 8 interests allowed'),
});

export const step3Schema = z.object({
  level: z
    .string()
    .refine(
      (val) => (LEVELS as readonly string[]).includes(val),
      { message: 'Choose a level to continue' }
    ),
});

export const step4Schema = z.object({
  goals: z
    .array(z.string())
    .min(1, 'Pick at least one goal')
    .max(3, 'Maximum 3 goals allowed'),
});

export const fullOnboardingSchema = step0Schema
  .merge(step1Schema)
  .merge(step2Schema)
  .merge(step3Schema)
  .merge(step4Schema)
  .extend({
    socials: z.object({}).passthrough().optional(),
  });

export type FullOnboardingData = z.infer<typeof fullOnboardingSchema>;

export const stepSchemas = [
  step0Schema,  // 0 — credentials
  step1Schema,  // 1 — profile
  step2Schema,  // 2 — interests
  step3Schema,  // 3 — level
  step4Schema,  // 4 — goals
  z.object({}), // 5 — socials (optional)
  z.object({}), // 6 — review
] as const;