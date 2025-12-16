import { NextRequest, NextResponse } from 'next/server';

// Configuration n8n - À configurer via variables d'environnement
const N8N_WEBHOOK_URL = process.env.N8N_WEBHOOK_URL || '';
const N8N_WORKFLOW_ID = process.env.N8N_WORKFLOW_ID || '';

export async function POST(request: NextRequest) {
  try {
    const { message } = await request.json();

    if (!message) {
      return NextResponse.json(
        { error: 'Message requis' },
        { status: 400 }
      );
    }

    // Si l'URL du webhook n8n est configurée, on l'utilise
    if (N8N_WEBHOOK_URL) {
      const response = await fetch(N8N_WEBHOOK_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          chatInput: message,
          type: 'chat',
        }),
      });

      if (!response.ok) {
        throw new Error(`n8n webhook error: ${response.status}`);
      }

      const data = await response.json();
      
      // Adapter selon la structure de réponse de votre workflow n8n
      return NextResponse.json({
        response: data.output || data.response || data.text || data.message || JSON.stringify(data),
      });
    }

    // Mode démo - Réponses simulées pour tester l'interface
    const demoResponses: Record<string, string> = {
      'bonjour': '¡Hola! 👋 Bienvenue chez Casa del Sabor ! Je suis ravi de vous accueillir. Que puis-je faire pour vous aujourd\'hui ?',
      'menu': '🌮 Voici nos spécialités :\n\n• Tacos al Pastor - 12€\n• Burrito Supremo - 14€\n• Enchiladas Verdes - 15€\n• Quesadillas de Pollo - 11€\n• Guacamole Fresco - 8€\n\n¿Qué le gustaría ordenar?',
      'réservation': '📅 Pour une réservation, j\'ai besoin de quelques informations :\n\n• Date souhaitée\n• Nombre de personnes\n• Heure préférée\n\nNos horaires : Mar-Dim, 12h-14h30 et 19h-22h30',
      'horaires': '🕐 Nos horaires d\'ouverture :\n\n• Mardi - Samedi : 12h-14h30 / 19h-22h30\n• Dimanche : 12h-15h (Brunch mexicain !)\n• Lundi : Fermé\n\n¡Los esperamos!',
      'adresse': '📍 Vous nous trouvez au :\n\n**Casa del Sabor**\n42 Rue des Épices\n75011 Paris\n\n🚇 Métro : Bastille (lignes 1, 5, 8)\n\n¡Hasta pronto!',
    };

    const lowerMessage = message.toLowerCase();
    let response = '🤔 Je ne suis pas sûr de comprendre. Puis-je vous aider avec :\n\n• Notre **menu**\n• Une **réservation**\n• Nos **horaires**\n• Notre **adresse**\n\nTapez l\'un de ces mots pour plus d\'infos !';

    for (const [key, value] of Object.entries(demoResponses)) {
      if (lowerMessage.includes(key)) {
        response = value;
        break;
      }
    }

    // Simuler un délai de réponse
    await new Promise(resolve => setTimeout(resolve, 800 + Math.random() * 700));

    return NextResponse.json({ response });

  } catch (error) {
    console.error('Erreur API chat:', error);
    return NextResponse.json(
      { error: 'Erreur interne du serveur', response: 'Désolé, une erreur s\'est produite. Veuillez réessayer.' },
      { status: 500 }
    );
  }
}

