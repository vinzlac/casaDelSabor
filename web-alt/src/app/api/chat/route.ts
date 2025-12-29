import { NextRequest, NextResponse } from 'next/server';

// URL de l'agent RAG Python - À configurer via variables d'environnement
const AGENT_URL = process.env.AGENT_URL || 'http://localhost:8000';

export async function POST(request: NextRequest) {
  try {
    const { message, sessionId } = await request.json();

    if (!message) {
      return NextResponse.json(
        { error: 'Message requis' },
        { status: 400 }
      );
    }

    // Appel à l'agent RAG Python
    try {
      const response = await fetch(`${AGENT_URL}/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
          message,
          session_id: sessionId || null,
        }),
      });

      if (!response.ok) {
        throw new Error(`Agent error: ${response.status}`);
      }

      const data = await response.json();
      
      return NextResponse.json({
        response: data.response,
        sources: data.sources || [],
        sessionId: data.session_id,
      });
    } catch (agentError) {
      console.warn('Agent RAG non disponible, utilisation du mode démo:', agentError);
      
      // Fallback: Mode démo si l'agent n'est pas disponible
      return handleDemoMode(message);
    }

  } catch (error) {
    console.error('Erreur API chat:', error);
    return NextResponse.json(
      { error: 'Erreur interne du serveur', response: 'Désolé, une erreur s\'est produite. Veuillez réessayer.' },
      { status: 500 }
    );
  }
}

/**
 * Mode démo - Réponses simulées quand l'agent RAG n'est pas disponible
 */
function handleDemoMode(message: string): NextResponse {
  const demoResponses: Record<string, string> = {
    'bonjour': '¡Hola! 👋 Bienvenue chez Casa del Sabor ! Je suis ravi de vous accueillir. Que puis-je faire pour vous aujourd\'hui ?\n\n⚠️ *Mode démo - Agent RAG non connecté*',
    'menu': '🌮 Voici nos spécialités :\n\n• Tacos al Pastor - 12€\n• Burrito Supremo - 14€\n• Enchiladas Verdes - 15€\n• Quesadillas de Pollo - 11€\n• Guacamole Fresco - 8€\n\n¿Qué le gustaría ordenar?\n\n⚠️ *Mode démo - Agent RAG non connecté*',
    'réservation': '📅 Pour une réservation, j\'ai besoin de quelques informations :\n\n• Date souhaitée\n• Nombre de personnes\n• Heure préférée\n\nNos horaires : Mar-Dim, 12h-14h30 et 19h-22h30\n\n⚠️ *Mode démo - Agent RAG non connecté*',
    'horaires': '🕐 Nos horaires d\'ouverture :\n\n• Mardi - Samedi : 12h-14h30 / 19h-22h30\n• Dimanche : 12h-15h (Brunch mexicain !)\n• Lundi : Fermé\n\n¡Los esperamos!\n\n⚠️ *Mode démo - Agent RAG non connecté*',
    'adresse': '📍 Vous nous trouvez au :\n\n**Casa del Sabor**\n42 Rue des Épices\n75011 Paris\n\n🚇 Métro : Bastille (lignes 1, 5, 8)\n\n¡Hasta pronto!\n\n⚠️ *Mode démo - Agent RAG non connecté*',
  };

  const lowerMessage = message.toLowerCase();
  let response = '🤔 Je ne suis pas sûr de comprendre. Puis-je vous aider avec :\n\n• Notre **menu**\n• Une **réservation**\n• Nos **horaires**\n• Notre **adresse**\n\nTapez l\'un de ces mots pour plus d\'infos !\n\n⚠️ *Mode démo - Agent RAG non connecté*';

  for (const [key, value] of Object.entries(demoResponses)) {
    if (lowerMessage.includes(key)) {
      response = value;
      break;
    }
  }

  return NextResponse.json({ response, sources: [], sessionId: null, demo: true });
}

