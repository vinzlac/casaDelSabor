export interface Message {
  id: string;
  content: string;
  sender: 'user' | 'bot';
  timestamp: Date;
}

export interface ChatState {
  messages: Message[];
  isLoading: boolean;
  sessionId: string | null;
}

export interface ChatResponse {
  response: string;
  sources?: string[];
  sessionId: string | null;
  demo?: boolean;
}

