'use client';

import { useState } from 'react';
import { Phone, Video, MoreVertical, RefreshCw } from 'lucide-react';

interface ChatHeaderProps {
  onReset?: () => void;
}

export default function ChatHeader({ onReset }: ChatHeaderProps) {
  const [showMenu, setShowMenu] = useState(false);

  return (
    <header className="chat-header">
      <div className="flex items-center gap-3">
        {/* Avatar */}
        <div className="avatar">
          <span className="text-xl">🍳</span>
        </div>
        
        {/* Info */}
        <div className="flex flex-col">
          <h1 className="font-semibold text-white text-[15px] leading-tight">
            Casa del Sabor
          </h1>
          <span className="text-[12px] text-emerald-100 flex items-center gap-1">
            <span className="w-2 h-2 bg-emerald-300 rounded-full animate-pulse"></span>
            En ligne
          </span>
        </div>
      </div>
      
      {/* Actions */}
      <div className="flex items-center gap-4">
        <button className="header-icon-btn" aria-label="Appel vidéo">
          <Video size={20} />
        </button>
        <button className="header-icon-btn" aria-label="Appel audio">
          <Phone size={20} />
        </button>
        
        {/* Menu avec options */}
        <div className="relative">
          <button 
            className="header-icon-btn" 
            aria-label="Plus d'options"
            onClick={() => setShowMenu(!showMenu)}
          >
            <MoreVertical size={20} />
          </button>
          
          {showMenu && (
            <>
              {/* Overlay pour fermer le menu */}
              <div 
                className="fixed inset-0 z-10" 
                onClick={() => setShowMenu(false)}
              />
              
              {/* Menu dropdown */}
              <div className="absolute right-0 top-full mt-2 bg-white rounded-lg shadow-lg py-2 min-w-[180px] z-20">
                <button
                  onClick={() => {
                    onReset?.();
                    setShowMenu(false);
                  }}
                  className="w-full px-4 py-2 text-left text-gray-700 hover:bg-gray-100 flex items-center gap-3"
                >
                  <RefreshCw size={16} />
                  Nouvelle conversation
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </header>
  );
}
