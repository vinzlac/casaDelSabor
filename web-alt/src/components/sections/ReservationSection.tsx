'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Calendar, Users, ArrowRight } from 'lucide-react';
import Link from 'next/link';

export default function ReservationSection() {
  return (
    <section className="py-20 px-4 bg-gradient-to-b from-white via-green-50 to-yellow-50">
      <div className="max-w-4xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-5xl font-bold text-primary mb-4 flex items-center justify-center gap-3">
            <Calendar className="h-10 w-10" />
            Réservez votre Table
          </h2>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Réservez dès maintenant pour garantir votre place, surtout le week-end et pour notre brunch du dimanche !
          </p>
        </div>

        <Card className="border-2 border-primary/20 shadow-xl">
          <CardHeader className="bg-gradient-to-r from-red-500 via-orange-500 to-yellow-500 text-white rounded-t-lg">
            <CardTitle className="text-2xl">Réservation en ligne</CardTitle>
          </CardHeader>
          <CardContent className="p-8">
            <div className="space-y-6">
              <div className="flex items-start gap-4">
                <div className="bg-primary/10 p-3 rounded-full">
                  <Calendar className="h-6 w-6 text-primary" />
                </div>
                <div>
                  <h3 className="font-bold text-lg mb-2">Choisissez votre date</h3>
                  <p className="text-gray-600">
                    Sélectionnez la date et l'heure qui vous conviennent
                  </p>
                </div>
              </div>

              <div className="flex items-start gap-4">
                <div className="bg-green-100 p-3 rounded-full">
                  <Users className="h-6 w-6 text-green-600" />
                </div>
                <div>
                  <h3 className="font-bold text-lg mb-2">Nombre de personnes</h3>
                  <p className="text-gray-600">
                    Indiquez le nombre de convives (groupes de 8+ : réservation obligatoire 48h à l'avance)
                  </p>
                </div>
              </div>

              <div className="pt-4 border-t">
                <p className="text-sm text-gray-600 mb-4">
                  💡 <strong>Conseil :</strong> Pour le brunch du dimanche, réservez à l'avance car c'est très demandé !
                </p>
                <Button
                  asChild
                  size="lg"
                  className="w-full bg-primary hover:bg-primary/90 text-lg py-6"
                >
                  <Link href="/reservation">
                    Réserver maintenant
                    <ArrowRight className="ml-2 h-5 w-5" />
                  </Link>
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </section>
  );
}

