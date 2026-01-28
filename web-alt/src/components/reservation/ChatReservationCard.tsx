'use client';

import { Card, CardContent } from '@/components/ui/card';
import { MessageCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';

export default function ChatReservationCard() {
  const handleOpenChat = () => {
    // Sauvegarder le message initial dans localStorage
    localStorage.setItem('chat_initial_message', 'Je souhaite réserver une table');
    
    // Chercher le bouton du chatbot et le cliquer
    const chatButton = document.querySelector('[aria-label="Ouvrir le chat"]') as HTMLButtonElement;
    if (chatButton) {
      chatButton.click();
      // Scroll smooth vers le bas pour voir le chat
      window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
    }
  };

  return (
    <Card className="border-2 border-primary/20 bg-gradient-to-br from-primary/5 to-orange-500/5 hover:shadow-lg transition-shadow">
      <CardContent className="p-6 text-center">
        <div className="relative">
          <MessageCircle className="h-8 w-8 text-primary mx-auto mb-2" />
          <div className="absolute -top-1 -right-1 w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
        </div>
        <h3 className="font-bold text-lg mb-2">Par Chat</h3>
        <p className="text-gray-600 mb-3 text-sm">Réponse instantanée</p>
        <Button
          onClick={handleOpenChat}
          variant="outline"
          size="sm"
          className="text-primary border-primary hover:bg-primary hover:text-white"
        >
          Ouvrir le chat
        </Button>
      </CardContent>
    </Card>
  );
}
