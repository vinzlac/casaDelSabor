'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Clock, Calendar } from 'lucide-react';

const hours = [
  { day: 'Lundi', lunch: 'Fermé', dinner: 'Fermé', closed: true },
  { day: 'Mardi', lunch: '12h00 - 14h30', dinner: '19h00 - 22h30' },
  { day: 'Mercredi', lunch: '12h00 - 14h30', dinner: '19h00 - 22h30' },
  { day: 'Jeudi', lunch: '12h00 - 14h30', dinner: '19h00 - 22h30' },
  { day: 'Vendredi', lunch: '12h00 - 14h30', dinner: '19h00 - 23h00' },
  { day: 'Samedi', lunch: '12h00 - 15h00', dinner: '19h00 - 23h00' },
  { day: 'Dimanche', lunch: '12h00 - 16h00 (Brunch)', dinner: 'Fermé', special: 'Brunch Mexicain' },
];

export default function HoursSection() {
  return (
    <section className="py-20 px-4 bg-gradient-to-b from-yellow-50 to-green-50">
      <div className="max-w-4xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-5xl font-bold text-primary mb-4 flex items-center justify-center gap-3">
            <Clock className="h-10 w-10" />
            Nos Horaires
          </h2>
          <p className="text-xl text-gray-600">
            Venez nous rendre visite pour découvrir nos saveurs authentiques
          </p>
        </div>

        <Card className="border-2 border-primary/20 shadow-xl">
          <CardHeader className="bg-gradient-to-r from-red-500 via-orange-500 to-yellow-500 text-white rounded-t-lg">
            <CardTitle className="text-2xl flex items-center gap-2">
              <Calendar className="h-6 w-6" />
              Horaires d'ouverture
            </CardTitle>
          </CardHeader>
          <CardContent className="p-6">
            <div className="space-y-3">
              {hours.map((hour, index) => (
                <div
                  key={index}
                  className={`flex items-center justify-between p-4 rounded-lg ${
                    hour.closed
                      ? 'bg-gray-100 text-gray-500'
                      : hour.special
                      ? 'bg-gradient-to-r from-yellow-100 to-orange-100 border-2 border-yellow-300'
                      : 'bg-white hover:bg-orange-50 transition-colors'
                  }`}
                >
                  <div className="flex-1">
                    <span className="font-bold text-lg text-primary">{hour.day}</span>
                    {hour.special && (
                      <span className="ml-2 text-sm font-semibold text-orange-600">
                        🌮 {hour.special}
                      </span>
                    )}
                  </div>
                  <div className="flex gap-6 text-right">
                    <div>
                      <span className="text-sm text-gray-600">Midi</span>
                      <p className="font-semibold">{hour.lunch}</p>
                    </div>
                    <div>
                      <span className="text-sm text-gray-600">Soir</span>
                      <p className="font-semibold">{hour.dinner}</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
            <div className="mt-6 p-4 bg-yellow-100 rounded-lg border-2 border-yellow-300">
              <p className="text-sm font-semibold text-orange-800">
                🌮 Brunch Mexicain du Dimanche : 28€ (12h-16h) - Réservation conseillée
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </section>
  );
}

