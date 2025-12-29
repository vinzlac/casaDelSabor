export interface Message {
  id: string;
  content: string;
  sender: 'user' | 'bot';
  timestamp: Date;
}

export interface ChatResponse {
  response: string;
  sources: string[];
  sessionId: string | null;
}
