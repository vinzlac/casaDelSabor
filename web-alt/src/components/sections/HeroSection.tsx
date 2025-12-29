'use client';

import { Button } from '@/components/ui/button';
import { ArrowRight, UtensilsCrossed } from 'lucide-react';
import Link from 'next/link';

export default function HeroSection() {
  return (
    <section className="relative min-h-[90vh] flex items-center justify-center bg-gradient-to-b from-green-500 via-yellow-500 to-red-500 overflow-hidden bg-mexican-pattern">
      {/* Pattern décoratif mexicain */}
      <div className="absolute inset-0 opacity-20">
        <div className="absolute top-10 left-10 w-32 h-32 border-4 border-white rounded-full animate-pulse"></div>
        <div className="absolute bottom-20 right-20 w-24 h-24 border-4 border-white rounded-full animate-pulse" style={{ animationDelay: '0.5s' }}></div>
        <div className="absolute top-1/2 left-1/4 w-16 h-16 border-4 border-white rounded-full animate-pulse" style={{ animationDelay: '1s' }}></div>
        <div className="absolute top-1/3 right-1/4 w-20 h-20 border-4 border-white rounded-full animate-pulse" style={{ animationDelay: '1.5s' }}></div>
      </div>
      
      {/* Motifs mexicains supplémentaires */}
      <div className="absolute inset-0 bg-mexican-dots opacity-30"></div>

      <div className="relative z-10 text-center px-4 max-w-4xl mx-auto">
        <div className="mb-6 inline-block">
          <UtensilsCrossed className="h-16 w-16 text-white animate-fiesta" />
        </div>
        <h1 className="text-4xl sm:text-6xl md:text-8xl font-bold text-white mb-6 drop-shadow-2xl">
          Casa del Sabor
        </h1>
        <p className="text-xl sm:text-2xl md:text-3xl text-white/90 mb-4 font-semibold">
          ¡La verdadera cocina mexicana en París!
        </p>
        <p className="text-lg sm:text-xl text-white/80 mb-8 max-w-2xl mx-auto px-4">
          Découvrez l'authenticité des saveurs mexicaines dans une ambiance festive et chaleureuse
        </p>
        <div className="flex flex-col sm:flex-row gap-4 justify-center px-4">
          <Button
            asChild
            size="lg"
            className="bg-white text-primary hover:bg-gray-100 text-lg px-8 py-6 h-auto"
          >
            <Link href="/menu">
              Voir le Menu
              <ArrowRight className="ml-2 h-5 w-5" />
            </Link>
          </Button>
          <Button
            asChild
            size="lg"
            variant="outline"
            className="border-2 border-white text-white hover:bg-white/10 text-lg px-8 py-6 h-auto"
          >
            <Link href="/reservation">
              Réserver une table
            </Link>
          </Button>
        </div>
      </div>
    </section>
  );
}

