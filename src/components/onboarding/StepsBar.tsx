import React from 'react';
import { cn } from '@/lib/utils';
import { STEP_LABELS, OnboardingStep } from '../../types/onboarding';

interface StepsBarProps {
  currentStep: OnboardingStep;
}

export const StepsBar: React.FC<StepsBarProps> = ({ currentStep }) => {
  return (
    <div className="mb-10">
      {/* Dots + lines */}
      <div className="flex items-center">
        {STEP_LABELS.map((_, i) => (
          <React.Fragment key={i}>
            <div
              className={cn(
                'w-7 h-7 rounded-full border flex items-center justify-center text-xs font-medium flex-shrink-0 transition-all duration-300',
                i < currentStep  && 'bg-amber-500 border-amber-500 text-white',
                i === currentStep && 'bg-white border-amber-500 text-amber-600 dark:bg-neutral-900',
                i > currentStep  && 'bg-white border-border text-muted-foreground dark:bg-neutral-900',
              )}
            >
              {i < currentStep ? '✓' : i + 1}
            </div>

            {i < STEP_LABELS.length - 1 && (
              <div
                className={cn(
                  'flex-1 h-px mx-1 transition-colors duration-300',
                  i < currentStep ? 'bg-amber-500' : 'bg-border',
                )}
              />
            )}
          </React.Fragment>
        ))}
      </div>

      {/* Labels */}
      <div className="flex justify-between mt-2">
        {STEP_LABELS.map((label, i) => (
          <span
            key={label}
            className={cn(
              'text-[11px] transition-colors duration-300 min-w-[52px] text-center',
              i === currentStep ? 'text-amber-600 font-medium' : 'text-muted-foreground',
            )}
          >
            {label}
          </span>
        ))}
      </div>
    </div>
  );
};
