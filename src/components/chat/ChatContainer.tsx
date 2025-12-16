'use client';

import { useState, useRef, useEffect, useCallback } from 'react';
import ChatHeader from './ChatHeader';
import ChatMessage from './ChatMessage';
import ChatInput from './ChatInput';
import TypingIndicator from './TypingIndicator';
import { Message } from '@/types/chat';

const INITIAL_MESSAGE: Message = {
  id: 'welcome',
  content: '¡Hola! 👋 Bienvenue chez Casa del Sabor ! Je suis votre assistant virtuel. Comment puis-je vous aider aujourd\'hui ?',
  sender: 'bot',
  timestamp: new Date(),
};

export default function ChatContainer() {
  const [messages, setMessages] = useState<Message[]>([INITIAL_MESSAGE]);
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const chatContainerRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = useCallback(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages, isLoading, scrollToBottom]);

  const sendMessage = async (content: string) => {
    // Ajouter le message utilisateur
    const userMessage: Message = {
      id: `user-${Date.now()}`,
      content,
      sender: 'user',
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setIsLoading(true);

    try {
      // Appel à l'API route qui communique avec n8n
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ message: content }),
      });

      const data = await response.json();

      // Ajouter la réponse du bot
      const botMessage: Message = {
        id: `bot-${Date.now()}`,
        content: data.response || 'Désolé, je n\'ai pas pu traiter votre demande.',
        sender: 'bot',
        timestamp: new Date(),
      };

      setMessages((prev) => [...prev, botMessage]);
    } catch (error) {
      console.error('Erreur lors de l\'envoi du message:', error);
      
      // Message d'erreur
      const errorMessage: Message = {
        id: `error-${Date.now()}`,
        content: 'Oups ! Une erreur s\'est produite. Veuillez réessayer.',
        sender: 'bot',
        timestamp: new Date(),
      };

      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="chat-container">
      <ChatHeader />
      
      {/* Zone des messages */}
      <div 
        ref={chatContainerRef}
        className="messages-area"
      >
        {/* Pattern de fond style WhatsApp */}
        <div className="chat-bg-pattern"></div>
        
        {/* Messages */}
        <div className="messages-list">
          {messages.map((message) => (
            <ChatMessage key={message.id} message={message} />
          ))}
          
          {isLoading && <TypingIndicator />}
          
          <div ref={messagesEndRef} />
        </div>
      </div>
      
      <ChatInput onSendMessage={sendMessage} isLoading={isLoading} />
    </div>
  );
}

