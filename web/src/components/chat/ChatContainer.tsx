'use client';

import { useState, useRef, useEffect, useCallback } from 'react';
import ChatHeader from './ChatHeader';
import ChatMessage from './ChatMessage';
import ChatInput from './ChatInput';
import TypingIndicator from './TypingIndicator';
import { Message } from '@/types/chat';

const STORAGE_KEY = 'casadelsabor_chat_history';
const SESSION_KEY = 'casadelsabor_session_id';

const createInitialMessage = (): Message => ({
  id: 'welcome',
  content: '¡Hola! 👋 Bienvenue chez Casa del Sabor ! Je suis votre assistant virtuel. Comment puis-je vous aider aujourd\'hui ?',
  sender: 'bot',
  timestamp: new Date(),
});

// Charger l'historique depuis localStorage
const loadChatHistory = (): Message[] => {
  if (typeof window === 'undefined') return [];
  
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) {
      const parsed = JSON.parse(saved);
      // Convertir les timestamps en objets Date
      return parsed.map((msg: any) => ({
        ...msg,
        timestamp: new Date(msg.timestamp),
      }));
    }
  } catch (error) {
    console.error('Erreur lors du chargement de l\'historique:', error);
  }
  
  return [createInitialMessage()];
};

// Charger le sessionId depuis localStorage
const loadSessionId = (): string | null => {
  if (typeof window === 'undefined') return null;
  
  try {
    return localStorage.getItem(SESSION_KEY);
  } catch (error) {
    console.error('Erreur lors du chargement de la session:', error);
    return null;
  }
};

export default function ChatContainer() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isInitialized, setIsInitialized] = useState(false);

  // Initialiser le message de bienvenue côté client uniquement
  useEffect(() => {
    if (!isInitialized) {
      const history = loadChatHistory();
      setMessages(history);
      setIsInitialized(true);
    }
  }, [isInitialized]);
  const [isLoading, setIsLoading] = useState(false);
  const [sessionId, setSessionId] = useState<string | null>(null);
  
  // Charger le sessionId
  useEffect(() => {
    if (isInitialized && !sessionId) {
      const savedSessionId = loadSessionId();
      if (savedSessionId) {
        setSessionId(savedSessionId);
      }
    }
  }, [isInitialized, sessionId]);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const chatContainerRef = useRef<HTMLDivElement>(null);

  const scrollToBottom = useCallback(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages, isLoading, scrollToBottom]);

  // Sauvegarder l'historique dans localStorage
  useEffect(() => {
    if (typeof window === 'undefined' || !isInitialized) return;
    
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(messages));
    } catch (error) {
      console.error('Erreur lors de la sauvegarde de l\'historique:', error);
    }
  }, [messages, isInitialized]);

  // Sauvegarder le sessionId dans localStorage
  useEffect(() => {
    if (typeof window === 'undefined' || !isInitialized) return;
    
    try {
      if (sessionId) {
        localStorage.setItem(SESSION_KEY, sessionId);
      }
    } catch (error) {
      console.error('Erreur lors de la sauvegarde de la session:', error);
    }
  }, [sessionId, isInitialized]);

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
      // Appel à l'API route qui communique avec l'agent RAG
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
          message: content,
          sessionId: sessionId,
        }),
      });

      const data = await response.json();

      // Sauvegarder le session_id pour maintenir la conversation
      if (data.sessionId) {
        setSessionId(data.sessionId);
      }

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

  // Fonction pour réinitialiser la conversation
  const resetConversation = () => {
    if (confirm('Voulez-vous vraiment effacer tout l\'historique de conversation ?')) {
      setMessages([createInitialMessage()]);
      setSessionId(null);
      localStorage.removeItem(STORAGE_KEY);
      localStorage.removeItem(SESSION_KEY);
    }
  };

  return (
    <div className="chat-container">
      <ChatHeader onReset={resetConversation} />
      
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
