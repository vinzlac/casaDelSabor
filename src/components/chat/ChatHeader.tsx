'use client';

import { Phone, Video, MoreVertical } from 'lucide-react';

export default function ChatHeader() {
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
      
      {/* Actions décoratives */}
      <div className="flex items-center gap-4">
        <button className="header-icon-btn" aria-label="Appel vidéo">
          <Video size={20} />
        </button>
        <button className="header-icon-btn" aria-label="Appel audio">
          <Phone size={20} />
        </button>
        <button className="header-icon-btn" aria-label="Plus d'options">
          <MoreVertical size={20} />
        </button>
      </div>
    </header>
  );
}

