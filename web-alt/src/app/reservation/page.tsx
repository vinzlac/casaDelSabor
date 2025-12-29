import { Metadata } from 'next';
import ReservationForm from '@/components/reservation/ReservationForm';
import { Card, CardContent } from '@/components/ui/card';
import { Phone, Mail, Calendar } from 'lucide-react';

export const metadata: Metadata = {
  title: 'Réservation - Casa del Sabor',
  description: 'Réservez votre table au restaurant Casa del Sabor. Brunch du dimanche, soirées Mariachi et ambiance festive garantie !',
};

export default function ReservationPage() {
  return (
    <main className="min-h-screen bg-gradient-to-b from-white via-orange-50 to-yellow-50 py-12">
      <div className="max-w-4xl mx-auto px-4">
        <div className="text-center mb-12">
          <h1 className="text-6xl font-bold text-primary mb-4">Réservez votre Table</h1>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Réservez dès maintenant pour garantir votre place, surtout le week-end et pour notre brunch du dimanche !
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-6 mb-8">
          <Card className="border-2 border-primary/20">
            <CardContent className="p-6 text-center">
              <Phone className="h-8 w-8 text-primary mx-auto mb-2" />
              <h3 className="font-bold text-lg mb-2">Par téléphone</h3>
              <p className="text-gray-600">01 42 55 12 34</p>
              <p className="text-sm text-gray-500 mt-1">Mar-Sam, 10h-22h</p>
            </CardContent>
          </Card>

          <Card className="border-2 border-primary/20">
            <CardContent className="p-6 text-center">
              <Mail className="h-8 w-8 text-primary mx-auto mb-2" />
              <h3 className="font-bold text-lg mb-2">Par email</h3>
              <p className="text-gray-600">contact@casadelsabor.fr</p>
            </CardContent>
          </Card>

          <Card className="border-2 border-primary/20">
            <CardContent className="p-6 text-center">
              <Calendar className="h-8 w-8 text-primary mx-auto mb-2" />
              <h3 className="font-bold text-lg mb-2">En ligne</h3>
              <p className="text-gray-600">Formulaire ci-dessous</p>
            </CardContent>
          </Card>
        </div>

        <ReservationForm />

        <div className="mt-8 p-6 bg-gradient-to-r from-red-500 via-orange-500 to-yellow-500 text-white rounded-lg">
          <h3 className="text-xl font-bold mb-4">Informations importantes</h3>
          <ul className="space-y-2 text-sm">
            <li>• Réservation recommandée le week-end et pour le brunch du dimanche</li>
            <li>• Groupes de plus de 8 personnes : réservation obligatoire 48h à l'avance</li>
            <li>• Annulation gratuite jusqu'à 24h avant</li>
            <li>• En cas de retard de plus de 15 minutes sans prévenir, la table peut être libérée</li>
          </ul>
        </div>
      </div>
    </main>
  );
}

