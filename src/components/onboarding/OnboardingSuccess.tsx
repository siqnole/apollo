import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { OnboardingFormData } from '../../types/onboarding';

interface OnboardingSuccessProps {
  form: OnboardingFormData;
}

const MOCK_RIVALS = [
  { initials: 'SK', color: '#C8922A' },
  { initials: 'AR', color: '#2A7DC8' },
  { initials: 'MJ', color: '#C82A2A' },
  { initials: 'PL', color: '#2AC87D' },
  { initials: 'DW', color: '#7D2AC8' },
];

export const OnboardingSuccess: React.FC<OnboardingSuccessProps> = ({ form }) => {
  const navigate = useNavigate();

  return (
    <div className="text-center py-6 px-4">
      <div className="w-16 h-16 rounded-full bg-amber-500 flex items-center justify-center mx-auto mb-6">
        <svg width="28" height="28" viewBox="0 0 24 24" fill="none">
          <path
            d="M12 2L15.09 8.26L22 9.27L17 14.14L18.18 21.02L12 17.77L5.82 21.02L7 14.14L2 9.27L8.91 8.26L12 2Z"
            fill="white"
          />
        </svg>
      </div>

      <h2 className="font-serif text-2xl font-semibold text-foreground mb-2">
        Welcome to the arena, {form.username}.
      </h2>
      <p className="text-sm text-muted-foreground max-w-xs mx-auto mb-6 leading-relaxed">
        We've found <strong>5 potential rivals</strong> based on your{' '}
        {form.interests.length} interests and {form.level} level. Your first faceoff awaits.
      </p>

      <div className="flex gap-2.5 justify-center mb-8">
        {MOCK_RIVALS.map((r, i) => (
          <div
            key={i}
            className="w-11 h-11 rounded-full flex items-center justify-center text-xs font-medium text-white border-2 border-amber-500"
            style={{ background: r.color }}
          >
            {r.initials}
          </div>
        ))}
      </div>

      <Button
        className="bg-amber-500 hover:bg-amber-600 text-white px-8 h-11"
        onClick={() => navigate('/dashboard')}
      >
        Enter Apollo →
      </Button>
    </div>
  );
};