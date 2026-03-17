/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: ['./src/**/*.{ts,tsx,js,jsx}'],
  theme: {
    extend: {
      colors: {
        background:  '#0A0906',
        foreground:  '#F0E8D6',
        card:        '#1C1812',
        'card-foreground': '#F0E8D6',
        border:      'rgba(201,168,76,0.18)',
        input:       'rgba(201,168,76,0.18)',
        ring:        '#C9A84C',
        muted:       '#161310',
        'muted-foreground': '#8A7D65',
        secondary:   '#161310',
        'secondary-foreground': '#F0E8D6',
        accent:      '#241F16',
        'accent-foreground': '#F0E8D6',
        destructive: '#E05C2A',
        'destructive-foreground': '#F0E8D6',
        primary:     '#C9A84C',
        'primary-foreground': '#0A0906',
        amber: {
          50:  '#fefce8',
          400: '#E8C97A',
          500: '#C9A84C',
          600: '#7A6230',
          950: '#1a1000',
        },
      },
      fontFamily: {
        serif: ['Cinzel', 'serif'],
        mono:  ['"DM Mono"', 'monospace'],
        sans:  ['"DM Sans"', 'sans-serif'],
      },
      borderRadius: {
        xl:  '0.75rem',
        '2xl': '1rem',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease',
        'slide-in-from-bottom-2': 'slideUp 0.3s ease',
      },
      keyframes: {
        fadeIn:  { from: { opacity: '0' }, to: { opacity: '1' } },
        slideUp: { from: { opacity: '0', transform: 'translateY(8px)' }, to: { opacity: '1', transform: 'translateY(0)' } },
      },
    },
  },
  plugins: [
    require('tailwindcss-animate'),
  ],
};
