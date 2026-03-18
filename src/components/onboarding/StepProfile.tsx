import React from 'react';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { OnboardingFormData, OnboardingErrors, NICHE_SUGGESTIONS } from '../../types/onboarding';

interface StepProfileProps {
  form: OnboardingFormData;
  errors: OnboardingErrors;
  onUsernameChange: (v: string) => void;
  onNicheChange: (v: string) => void;
  onBioChange: (v: string) => void;
}

export const StepProfile: React.FC<StepProfileProps> = ({
  form, errors,
  onUsernameChange, onNicheChange, onBioChange,
}) => (
  <div className="space-y-5">
    <div>
      <h2 className="font-serif text-xl font-semibold text-foreground">Who are you, challenger?</h2>
      <p className="text-sm text-muted-foreground mt-1">
        Set up your Apollo identity — this is how rivals will know you.
      </p>
    </div>

    <div className="space-y-1">
      <Label htmlFor="username">Username</Label>
      <Input
        id="username"
        placeholder="e.g. codewarrior99"
        maxLength={20}
        value={form.username}
        onChange={(e: React.ChangeEvent<HTMLInputElement>) => onUsernameChange(e.target.value)}
        className={errors.username ? 'border-destructive' : ''}
      />
      <div className="flex justify-between items-center">
        {errors.username
          ? <p className="text-xs text-destructive">{errors.username}</p>
          : <span />
        }
        <span className="text-xs text-muted-foreground">{form.username.length}/20</span>
      </div>
    </div>

    <div className="space-y-1">
      <Label htmlFor="niche">
        Your niche{' '}
        <span className="text-destructive">*</span>
      </Label>
      <Input
        id="niche"
        list="niches"
        placeholder="e.g. Physics & mechanics enthusiast"
        maxLength={80}
        value={form.niche}
        onChange={(e: React.ChangeEvent<HTMLInputElement>) => onNicheChange(e.target.value)}
      />
      <datalist id="niches">
        {NICHE_SUGGESTIONS.map(niche => (
          <option key={niche} value={niche} />
        ))}
      </datalist>
    </div>

    <div className="space-y-1">
      <Label htmlFor="bio">
        Bio{' '}
        <span className="text-muted-foreground font-normal">(optional)</span>
      </Label>
      <Textarea
        id="bio"
        placeholder="Tell rivals what makes you worth defeating..."
        className="resize-none h-20"
        maxLength={500}
        value={form.bio}
        onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => onBioChange(e.target.value)}
      />
    </div>
  </div>
);