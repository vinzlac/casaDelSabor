'use client';

import { Card, CardContent } from '@/components/ui/card';
import { Heart, Users, Award } from 'lucide-react';

export default function AboutSection() {
  return (
    <section className="py-20 px-4 bg-gradient-to-b from-red-50 to-orange-50 bg-mexican-pattern relative">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-5xl font-bold text-primary mb-4">
            Notre Histoire
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Une passion pour la cuisine mexicaine authentique
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-8 mb-12">
          <Card className="border-2 border-primary/20 shadow-lg">
            <CardContent className="p-6">
              <p className="text-lg text-gray-700 leading-relaxed mb-4">
                Casa del Sabor a été fondé en 2018 par Maria et Carlos Rodriguez, un couple franco-mexicain passionné de gastronomie. Leur mission : faire découvrir la vraie cuisine mexicaine, loin des clichés, dans une ambiance chaleureuse et conviviale.
              </p>
              <p className="text-lg text-gray-700 leading-relaxed">
                Toutes nos recettes sont inspirées des traditions familiales de Carlos, originaire de Oaxaca, et adaptées avec des produits français de qualité.
              </p>
            </CardContent>
          </Card>

          <div className="space-y-6">
            <Card className="border-2 border-green-300 bg-green-50">
              <CardContent className="p-6">
                <div className="flex items-start gap-4">
                  <Award className="h-8 w-8 text-green-600 flex-shrink-0 mt-1" />
                  <div>
                    <h3 className="font-bold text-lg text-green-800 mb-2">Qualité</h3>
                    <p className="text-gray-700">
                      Produits frais livrés quotidiennement, tortillas faites maison chaque jour, viandes françaises de qualité.
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="border-2 border-blue-300 bg-blue-50">
              <CardContent className="p-6">
                <div className="flex items-start gap-4">
                  <Heart className="h-8 w-8 text-blue-600 flex-shrink-0 mt-1" />
                  <div>
                    <h3 className="font-bold text-lg text-blue-800 mb-2">Ambiance</h3>
                    <p className="text-gray-700">
                      Une atmosphère festive et chaleureuse qui vous transporte au cœur du Mexique. Soirées Mariachi tous les vendredis !
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card className="border-2 border-yellow-300 bg-yellow-50">
              <CardContent className="p-6">
                <div className="flex items-start gap-4">
                  <Users className="h-8 w-8 text-yellow-600 flex-shrink-0 mt-1" />
                  <div>
                    <h3 className="font-bold text-lg text-yellow-800 mb-2">Communauté</h3>
                    <p className="text-gray-700">
                      Équipe 100% en CDI, formation continue, partenariats avec des producteurs locaux.
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </section>
  );
}

