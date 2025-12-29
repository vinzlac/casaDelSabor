'use client';

import { useState, useRef, useEffect, useCallback } from 'react';
import { Message } from '@/types/chat';
import { sendChatMessage } from '@/lib/api';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
import { X, Send, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card } from '@/components/ui/card';

const createInitialMessage = (): Message => ({
  id: 'welcome',
  content: '¡Hola! 👋 Bienvenue chez Casa del Sabor ! Je suis votre assistant virtuel. Comment puis-je vous aider aujourd\'hui ?',
  sender: 'bot',
  timestamp: new Date(),
});

interface ChatWindowProps {
  onClose: () => void;
}

export default function ChatWindow({ onClose }: ChatWindowProps) {
  const [messages, setMessages] = useState<Message[]>([createInitialMessage()]);
  const [isLoading, setIsLoading] = useState(false);
  const [sessionId, setSessionId] = useState<string | null>(null);
  const [input, setInput] = useState('');
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const scrollToBottom = useCallback(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages, isLoading, scrollToBottom]);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  const handleSend = async () => {
    if (!input.trim() || isLoading) return;

    const userMessage: Message = {
      id: `user-${Date.now()}`,
      content: input.trim(),
      sender: 'user',
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);

    try {
      const data = await sendChatMessage(input.trim(), sessionId);

      if (data.sessionId) {
        setSessionId(data.sessionId);
      }

      const botMessage: Message = {
        id: `bot-${Date.now()}`,
        content: data.response || 'Désolé, je n\'ai pas pu traiter votre demande.',
        sender: 'bot',
        timestamp: new Date(),
      };

      setMessages((prev) => [...prev, botMessage]);
    } catch (error) {
      console.error('Erreur lors de l\'envoi du message:', error);
      const errorMessage: Message = {
        id: `error-${Date.now()}`,
        content: 'Oups ! Une erreur s\'est produite. Veuillez réessayer.',
        sender: 'bot',
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
      inputRef.current?.focus();
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <Card className="flex flex-col h-full w-full bg-white shadow-2xl border-2 border-primary/20">
      {/* Header */}
      <div className="flex items-center justify-between p-4 border-b bg-gradient-to-r from-red-500 via-orange-500 to-yellow-500 text-white rounded-t-lg">
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 bg-green-400 rounded-full animate-pulse"></div>
          <h3 className="font-bold text-lg">Casa del Sabor</h3>
        </div>
        <Button
          variant="ghost"
          size="icon"
          onClick={onClose}
          className="text-white hover:bg-white/20 h-8 w-8"
        >
          <X className="h-4 w-4" />
        </Button>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gradient-to-b from-orange-50/50 to-yellow-50/50">
        {messages.map((message) => {
          const isUser = message.sender === 'user';
          return (
            <div
              key={message.id}
              className={`flex ${isUser ? 'justify-end' : 'justify-start'}`}
            >
              <div
                className={`max-w-[80%] rounded-2xl px-4 py-2 ${
                  isUser
                    ? 'bg-primary text-primary-foreground'
                    : 'bg-white text-gray-800 shadow-md border border-gray-200'
                }`}
              >
                <p className="text-sm whitespace-pre-wrap">{message.content}</p>
                <p className="text-xs mt-1 opacity-70">
                  {format(message.timestamp, 'HH:mm', { locale: fr })}
                </p>
              </div>
            </div>
          );
        })}
        {isLoading && (
          <div className="flex justify-start">
            <div className="bg-white rounded-2xl px-4 py-2 shadow-md border border-gray-200">
              <Loader2 className="h-4 w-4 animate-spin text-primary" />
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="p-4 border-t bg-white">
        <div className="flex gap-2">
          <Input
            ref={inputRef}
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Tapez votre message..."
            disabled={isLoading}
            className="flex-1"
          />
          <Button
            onClick={handleSend}
            disabled={isLoading || !input.trim()}
            className="bg-primary hover:bg-primary/90"
            size="icon"
          >
            <Send className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </Card>
  );
}

