'use client';

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Utensils, ArrowRight } from 'lucide-react';
import Link from 'next/link';

const featuredItems = [
  {
    id: 'tacos-pastor',
    name: 'Tacos al Pastor',
    description: 'Porc mariné à l\'achiote, ananas, oignon, coriandre',
    price: 12,
    emoji: '🌮',
  },
  {
    id: 'burrito',
    name: 'Burrito Supremo',
    description: 'Grande tortilla garnie de riz, haricots, fromage et votre choix de protéine',
    price: 14,
    emoji: '🌯',
  },
  {
    id: 'enchiladas',
    name: 'Enchiladas Verdes',
    description: 'Tortillas roulées nappées de sauce tomatillo verte',
    price: 15,
    emoji: '🍽️',
  },
  {
    id: 'guacamole',
    name: 'Guacamole Fresco',
    description: 'Avocat frais avec tomates, oignons, coriandre et jalapeño',
    price: 8,
    emoji: '🥑',
  },
];

export default function MenuSection() {
  return (
    <section className="py-20 px-4 bg-gradient-to-b from-white to-orange-50 bg-mexican-stripes relative">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-12">
          <h2 className="text-3xl sm:text-4xl md:text-5xl font-bold text-primary mb-4 flex items-center justify-center gap-3">
            <Utensils className="h-8 w-8 md:h-10 md:w-10" />
            Nos Spécialités
          </h2>
          <p className="text-lg sm:text-xl text-gray-600 max-w-2xl mx-auto px-4">
            Découvrez nos plats emblématiques préparés avec des recettes authentiques
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {featuredItems.map((item) => (
            <Card
              key={item.id}
              className="border-2 border-orange-200 hover:border-primary transition-all hover:shadow-xl hover:scale-105"
            >
              <CardHeader>
                <div className="text-4xl mb-2">{item.emoji}</div>
                <CardTitle className="text-xl text-primary">{item.name}</CardTitle>
                <CardDescription className="text-sm">{item.description}</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="flex items-center justify-between">
                  <span className="text-2xl font-bold text-primary">{item.price}€</span>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>

        <div className="text-center">
          <Button
            asChild
            size="lg"
            className="bg-primary hover:bg-primary/90 text-lg px-8"
          >
            <Link href="/menu">
              Voir tout le menu
              <ArrowRight className="ml-2 h-5 w-5" />
            </Link>
          </Button>
        </div>
      </div>
    </section>
  );
}

