'use client';

import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
import { Check, CheckCheck } from 'lucide-react';
import { Message } from '@/types/chat';

interface ChatMessageProps {
  message: Message;
}

export default function ChatMessage({ message }: ChatMessageProps) {
  const isUser = message.sender === 'user';
  
  return (
    <div 
      className={`message-wrapper ${isUser ? 'justify-end' : 'justify-start'}`}
    >
      <div 
        className={`message-bubble ${isUser ? 'message-user' : 'message-bot'}`}
      >
        {/* Contenu du message */}
        <p className="message-content whitespace-pre-wrap">
          {message.content}
        </p>
        
        {/* Timestamp et statut */}
        <div className={`message-meta ${isUser ? 'text-emerald-100' : 'text-gray-400'}`}>
          <span className="text-[10px]">
            {format(new Date(message.timestamp), 'HH:mm', { locale: fr })}
          </span>
          {isUser && (
            <CheckCheck size={14} className="text-sky-200" />
          )}
        </div>
      </div>
    </div>
  );
}

