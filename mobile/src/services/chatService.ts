import { API_URL } from '../config/api';
import { ChatResponse } from '../types/chat';

export async function sendMessage(
  message: string,
  sessionId: string | null
): Promise<ChatResponse> {
  try {
    const response = await fetch(`${API_URL}/chat`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message,
        session_id: sessionId,
      }),
    });

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }

    const data = await response.json();

    return {
      response: data.response,
      sources: data.sources || [],
      sessionId: data.session_id,
    };
  } catch (error) {
    console.error('Erreur API:', error);
    throw error;
  }
}
