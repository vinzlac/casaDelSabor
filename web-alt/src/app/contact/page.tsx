import { Metadata } from 'next';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { MapPin, Phone, Mail, Globe, Instagram, Facebook, Clock, Train, Bike, Car } from 'lucide-react';
import Link from 'next/link';

export const metadata: Metadata = {
  title: 'Contact - Casa del Sabor',
  description: 'Contactez Casa del Sabor - Restaurant mexicain à Paris. Adresse, horaires, téléphone et réseaux sociaux.',
};

export default function ContactPage() {
  return (
    <main className="min-h-screen bg-gradient-to-b from-white via-orange-50 to-yellow-50 py-12">
      <div className="max-w-6xl mx-auto px-4">
        <div className="text-center mb-12">
          <h1 className="text-6xl font-bold text-primary mb-4">Contactez-nous</h1>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Nous sommes là pour répondre à toutes vos questions
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-8 mb-12">
          {/* Informations de contact */}
          <div className="space-y-6">
            <Card className="border-2 border-primary/20 shadow-lg">
              <CardHeader className="bg-gradient-to-r from-red-500 via-orange-500 to-yellow-500 text-white rounded-t-lg">
                <CardTitle className="text-2xl">Informations</CardTitle>
              </CardHeader>
              <CardContent className="p-6 space-y-4">
                <div className="flex items-start gap-4">
                  <MapPin className="h-6 w-6 text-primary flex-shrink-0 mt-1" />
                  <div>
                    <h3 className="font-bold text-lg mb-1">Adresse</h3>
                    <p className="text-gray-700">
                      Casa del Sabor<br />
                      42 Rue des Épices<br />
                      75011 Paris, France
                    </p>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <Phone className="h-6 w-6 text-primary flex-shrink-0 mt-1" />
                  <div>
                    <h3 className="font-bold text-lg mb-1">Téléphone</h3>
                    <Link href="tel:0142551234" className="text-primary hover:underline">
                      01 42 55 12 34
                    </Link>
                    <p className="text-sm text-gray-500 mt-1">Mar-Sam, 10h-22h</p>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <Mail className="h-6 w-6 text-primary flex-shrink-0 mt-1" />
                  <div>
                    <h3 className="font-bold text-lg mb-1">Email</h3>
                    <Link href="mailto:contact@casadelsabor.fr" className="text-primary hover:underline">
                      contact@casadelsabor.fr
                    </Link>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <Globe className="h-6 w-6 text-primary flex-shrink-0 mt-1" />
                  <div>
                    <h3 className="font-bold text-lg mb-1">Site web</h3>
                    <Link href="https://www.casadelsabor.fr" className="text-primary hover:underline" target="_blank">
                      www.casadelsabor.fr
                    </Link>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Réseaux sociaux */}
            <Card className="border-2 border-primary/20 shadow-lg">
              <CardHeader className="bg-gradient-to-r from-red-500 via-orange-500 to-yellow-500 text-white rounded-t-lg">
                <CardTitle className="text-2xl">Suivez-nous</CardTitle>
              </CardHeader>
              <CardContent className="p-6">
                <div className="flex gap-4">
                  <Link
                    href="https://instagram.com/casadelsabor_paris"
                    target="_blank"
                    className="flex items-center gap-2 p-3 bg-pink-100 hover:bg-pink-200 rounded-lg transition-colors"
                  >
                    <Instagram className="h-6 w-6 text-pink-600" />
                    <span className="font-semibold text-pink-800">Instagram</span>
                  </Link>
                  <Link
                    href="https://facebook.com/casadelsaborparis"
                    target="_blank"
                    className="flex items-center gap-2 p-3 bg-blue-100 hover:bg-blue-200 rounded-lg transition-colors"
                  >
                    <Facebook className="h-6 w-6 text-blue-600" />
                    <span className="font-semibold text-blue-800">Facebook</span>
                  </Link>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Carte et accès */}
          <div className="space-y-6">
            <Card className="border-2 border-primary/20 shadow-lg">
              <CardHeader className="bg-gradient-to-r from-red-500 via-orange-500 to-yellow-500 text-white rounded-t-lg">
                <CardTitle className="text-2xl">Comment venir ?</CardTitle>
              </CardHeader>
              <CardContent className="p-6 space-y-4">
                <div className="flex items-start gap-4">
                  <Train className="h-6 w-6 text-primary flex-shrink-0 mt-1" />
                  <div>
                    <h3 className="font-bold text-lg mb-2">En métro</h3>
                    <ul className="text-gray-700 space-y-1">
                      <li>• Ligne 1, 5, 8 : Station <strong>Bastille</strong> (5 min à pied)</li>
                      <li>• Ligne 8 : Station <strong>Ledru-Rollin</strong> (3 min à pied)</li>
                    </ul>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <Bike className="h-6 w-6 text-primary flex-shrink-0 mt-1" />
                  <div>
                    <h3 className="font-bold text-lg mb-2">En vélo</h3>
                    <p className="text-gray-700">
                      Station Vélib' à 50 mètres<br />
                      Parking vélo devant le restaurant
                    </p>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <Car className="h-6 w-6 text-primary flex-shrink-0 mt-1" />
                  <div>
                    <h3 className="font-bold text-lg mb-2">En voiture</h3>
                    <p className="text-gray-700">
                      Parking public "Bastille" à 200 mètres (payant)<br />
                      <span className="text-sm text-orange-600">Attention : stationnement difficile dans le quartier</span>
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Carte Google Maps */}
            <Card className="border-2 border-primary/20 shadow-lg overflow-hidden">
              <CardHeader className="bg-gradient-to-r from-red-500 via-orange-500 to-yellow-500 text-white">
                <CardTitle className="text-2xl flex items-center gap-2">
                  <MapPin className="h-6 w-6" />
                  Localisation
                </CardTitle>
              </CardHeader>
              <CardContent className="p-0">
                <iframe
                  src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2624.9916256937596!2d2.3694!3d48.8522!2m3!1f0!2f0!3f0!3m2!1f1024!2f768!4f13.1!3m3!1m2!1s0x0%3A0x0!2zNDjCsDUxJzA3LjkiTiAywrAyMicwOS44IkU!5e0!3m2!1sfr!2sfr!4v1234567890123!5m2!1sfr!2sfr"
                  width="100%"
                  height="300"
                  style={{ border: 0 }}
                  allowFullScreen
                  loading="lazy"
                  referrerPolicy="no-referrer-when-downgrade"
                  className="w-full"
                />
              </CardContent>
            </Card>
          </div>
        </div>

        {/* Horaires détaillés */}
        <Card className="border-2 border-primary/20 shadow-lg">
          <CardHeader className="bg-gradient-mexican text-white rounded-t-lg">
            <CardTitle className="text-2xl flex items-center gap-2">
              <Clock className="h-6 w-6" />
              Horaires d'ouverture
            </CardTitle>
          </CardHeader>
          <CardContent className="p-6">
            <div className="grid md:grid-cols-2 gap-6">
              <div>
                <h3 className="font-bold text-lg mb-4">Horaires réguliers</h3>
                <div className="space-y-2 text-gray-700">
                  <div className="flex justify-between">
                    <span>Lundi</span>
                    <span className="text-gray-500">Fermé</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Mardi - Jeudi</span>
                    <span>12h-14h30 / 19h-22h30</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Vendredi</span>
                    <span>12h-14h30 / 19h-23h</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Samedi</span>
                    <span>12h-15h / 19h-23h</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Dimanche</span>
                    <span className="text-orange-600 font-semibold">12h-16h (Brunch)</span>
                  </div>
                </div>
              </div>
              <div className="bg-yellow-50 p-4 rounded-lg border-2 border-yellow-300">
                <h3 className="font-bold text-lg mb-2 text-orange-800">🌮 Brunch Mexicain</h3>
                <p className="text-sm text-gray-700 mb-2">
                  Tous les dimanches de 12h à 16h
                </p>
                <p className="text-sm font-semibold text-orange-800">
                  Formule à 28€ - Réservation fortement conseillée
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </main>
  );
}

