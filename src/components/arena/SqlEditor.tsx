import React from 'react';
import CodeMirror from '@uiw/react-codemirror';
import { oneDark } from '@codemirror/theme-one-dark';
import { EditorView } from '@codemirror/view';

// To get proper SQL syntax highlighting, run:
//   npm install @codemirror/lang-sql
// Then replace the import and sqlExtension below with:
//   import { sql } from '@codemirror/lang-sql';
//   const sqlExtension = sql();
import { javascript } from '@codemirror/lang-javascript';
const sqlExtension = javascript();

const dim    = '#4A4236';
const border = 'rgba(201,168,76,0.18)';
const bg     = '#0A0906';

const apolloTheme = EditorView.theme({
  '&': { backgroundColor: '#0F0D09', color: '#F0E8D6', height: '100%' },
  '.cm-content': { padding: '1.25rem', fontFamily: '"DM Mono", monospace', fontSize: '0.85rem', lineHeight: '1.6' },
  '.cm-gutters': { backgroundColor: '#0A0906', borderRight: '1px solid rgba(201,168,76,0.12)', color: '#4A4236' },
  '.cm-activeLine': { backgroundColor: 'rgba(201,168,76,0.04)' },
  '.cm-cursor': { borderLeftColor: '#C9A84C' },
  '.cm-selectionBackground': { backgroundColor: 'rgba(201,168,76,0.15) !important' },
  '.cm-scroller': { overflow: 'auto' },
}, { dark: true });

interface Props {
  value:    string;
  onChange: (v: string) => void;
}

export default function SqlEditor({ value, onChange }: Props) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      <div style={{
        padding: '0.4rem 1rem', borderBottom: `1px solid ${border}`,
        fontFamily: 'DM Mono, monospace', fontSize: '0.6rem', letterSpacing: '0.15em',
        textTransform: 'uppercase' as const, color: dim, background: bg, flexShrink: 0,
        display: 'flex', alignItems: 'center', gap: '0.75rem',
      }}>
        <span>SQL</span>
        <span style={{ color: '#4ADE80', fontSize: '0.55rem' }}>PostgreSQL</span>
      </div>
      <CodeMirror
        value={value}
        height="100%"
        theme={[oneDark, apolloTheme]}
        extensions={[sqlExtension, EditorView.lineWrapping]}
        onChange={onChange}
        basicSetup={{
          lineNumbers: true, highlightActiveLine: true,
          bracketMatching: true, autocompletion: true,
          indentOnInput: true, tabSize: 2, foldGutter: false,
        }}
        style={{ flex: 1, fontSize: '0.85rem', overflow: 'hidden' }}
      />
    </div>
  );
}