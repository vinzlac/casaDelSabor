'use client';

import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';

interface MarkdownMessageProps {
  content: string;
  className?: string;
}

export default function MarkdownMessage({ content, className = '' }: MarkdownMessageProps) {
  return (
    <div className={`prose prose-sm max-w-none ${className}`}>
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        components={{
        // Paragraphes
        p: ({ children }) => (
          <p className="mb-2 last:mb-0">{children}</p>
        ),
        // Texte en gras
        strong: ({ children }) => (
          <strong className="font-bold text-gray-900">{children}</strong>
        ),
        // Texte en italique
        em: ({ children }) => (
          <em className="italic">{children}</em>
        ),
        // Listes à puces
        ul: ({ children }) => (
          <ul className="list-disc list-inside mb-2 space-y-1">{children}</ul>
        ),
        // Listes numérotées
        ol: ({ children }) => (
          <ol className="list-decimal list-inside mb-2 space-y-1">{children}</ol>
        ),
        // Items de liste
        li: ({ children }) => (
          <li className="ml-2">{children}</li>
        ),
        // Titres
        h1: ({ children }) => (
          <h1 className="text-xl font-bold mb-2 mt-3 first:mt-0">{children}</h1>
        ),
        h2: ({ children }) => (
          <h2 className="text-lg font-bold mb-2 mt-3 first:mt-0">{children}</h2>
        ),
        h3: ({ children }) => (
          <h3 className="text-base font-bold mb-2 mt-2 first:mt-0">{children}</h3>
        ),
        // Code inline
        code: ({ children, className }) => {
          const isInline = !className;
          if (isInline) {
            return (
              <code className="bg-gray-100 text-red-600 px-1.5 py-0.5 rounded text-xs font-mono">
                {children}
              </code>
            );
          }
          // Code block
          return (
            <code className="block bg-gray-100 p-2 rounded text-xs font-mono overflow-x-auto">
              {children}
            </code>
          );
        },
        // Blocs de citation
        blockquote: ({ children }) => (
          <blockquote className="border-l-4 border-primary pl-3 italic my-2">
            {children}
          </blockquote>
        ),
        // Liens
        a: ({ href, children }) => (
          <a
            href={href}
            target="_blank"
            rel="noopener noreferrer"
            className="text-primary hover:underline"
          >
            {children}
          </a>
        ),
        // Séparateur horizontal
        hr: () => (
          <hr className="my-3 border-gray-300" />
        ),
      }}
      >
        {content}
      </ReactMarkdown>
    </div>
  );
}
