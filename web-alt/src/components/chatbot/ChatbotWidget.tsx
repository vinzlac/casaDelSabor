'use client';

import { useState } from 'react';
import { MessageCircle, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import ChatWindow from './ChatWindow';

export default function ChatbotWidget() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="fixed bottom-4 right-4 md:bottom-6 md:right-6 z-50">
      {isOpen ? (
        <div className="w-[calc(100vw-2rem)] md:w-[380px] h-[calc(100vh-8rem)] md:h-[600px] max-h-[600px] animate-in slide-in-from-bottom-5 fade-in-0 duration-300">
          <ChatWindow onClose={() => setIsOpen(false)} />
        </div>
      ) : (
        <Button
          onClick={() => setIsOpen(true)}
          size="lg"
          className="rounded-full h-14 w-14 md:h-16 md:w-16 bg-gradient-to-br from-red-500 via-orange-500 to-yellow-500 hover:scale-110 transition-transform shadow-2xl animate-fiesta"
          aria-label="Ouvrir le chat"
        >
          <MessageCircle className="h-5 w-5 md:h-6 md:w-6 text-white" />
        </Button>
      )}
    </div>
  );
}

