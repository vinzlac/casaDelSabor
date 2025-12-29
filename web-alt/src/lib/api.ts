import { ChatResponse } from '@/types/chat';

export async function sendChatMessage(
  message: string,
  sessionId: string | null = null
): Promise<ChatResponse> {
  const response = await fetch('/api/chat', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message,
      sessionId,
    }),
  });

  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }

  return response.json();
}

