'use client';

export default function TypingIndicator() {
  return (
    <div className="message-wrapper justify-start">
      <div className="message-bubble message-bot py-3 px-4">
        <div className="typing-indicator">
          <span className="typing-dot"></span>
          <span className="typing-dot"></span>
          <span className="typing-dot"></span>
        </div>
      </div>
    </div>
  );
}

