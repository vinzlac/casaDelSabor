'use client';

import { useState, KeyboardEvent } from 'react';
import { Send, Smile, Paperclip, Mic } from 'lucide-react';

interface ChatInputProps {
  onSendMessage: (message: string) => void;
  isLoading: boolean;
}

export default function ChatInput({ onSendMessage, isLoading }: ChatInputProps) {
  const [input, setInput] = useState('');

  const handleSend = () => {
    if (input.trim() && !isLoading) {
      onSendMessage(input.trim());
      setInput('');
    }
  };

  const handleKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <footer className="chat-input-container">
      <div className="input-wrapper">
        {/* Bouton emoji */}
        <button 
          className="input-icon-btn"
          aria-label="Emojis"
          type="button"
        >
          <Smile size={22} className="text-gray-500" />
        </button>
        
        {/* Bouton pièce jointe */}
        <button 
          className="input-icon-btn"
          aria-label="Pièce jointe"
          type="button"
        >
          <Paperclip size={22} className="text-gray-500" />
        </button>
        
        {/* Input */}
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="Tapez votre message..."
          disabled={isLoading}
          className="chat-input"
        />
        
        {/* Bouton micro ou envoi */}
        {input.trim() ? (
          <button
            onClick={handleSend}
            disabled={isLoading}
            className="send-btn"
            aria-label="Envoyer"
            type="button"
          >
            <Send size={20} className="text-white ml-0.5" />
          </button>
        ) : (
          <button 
            className="mic-btn"
            aria-label="Message vocal"
            type="button"
          >
            <Mic size={22} className="text-white" />
          </button>
        )}
      </div>
    </footer>
  );
}

