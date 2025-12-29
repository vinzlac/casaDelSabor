'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Calendar, Users, Mail, Phone, CheckCircle2 } from 'lucide-react';

export default function ReservationForm() {
  const [formData, setFormData] = useState({
    date: '',
    time: '',
    guests: '2',
    name: '',
    email: '',
    phone: '',
    notes: '',
  });
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);

    // Simuler l'envoi (à remplacer par un appel API réel)
    await new Promise((resolve) => setTimeout(resolve, 1500));

    setIsSubmitting(false);
    setIsSubmitted(true);
  };

  if (isSubmitted) {
    return (
      <Card className="border-2 border-green-300 bg-green-50">
        <CardContent className="p-8 text-center">
          <CheckCircle2 className="h-16 w-16 text-green-600 mx-auto mb-4" />
          <h3 className="text-2xl font-bold text-green-800 mb-2">Réservation confirmée !</h3>
          <p className="text-gray-700 mb-4">
            Nous avons bien reçu votre demande de réservation. Vous recevrez un email de confirmation sous peu.
          </p>
          <Button
            onClick={() => {
              setIsSubmitted(false);
              setFormData({
                date: '',
                time: '',
                guests: '2',
                name: '',
                email: '',
                phone: '',
                notes: '',
              });
            }}
            className="bg-primary hover:bg-primary/90"
          >
            Nouvelle réservation
          </Button>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="border-2 border-primary/20 shadow-xl">
      <CardHeader className="bg-gradient-to-r from-red-500 via-orange-500 to-yellow-500 text-white rounded-t-lg">
        <CardTitle className="text-2xl flex items-center gap-2">
          <Calendar className="h-6 w-6" />
          Formulaire de réservation
        </CardTitle>
        <CardDescription className="text-white/90">
          Remplissez le formulaire ci-dessous pour réserver votre table
        </CardDescription>
      </CardHeader>
      <CardContent className="p-6">
        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-2">
              <Label htmlFor="date" className="flex items-center gap-2">
                <Calendar className="h-4 w-4" />
                Date
              </Label>
              <Input
                id="date"
                name="date"
                type="date"
                value={formData.date}
                onChange={handleChange}
                required
                min={new Date().toISOString().split('T')[0]}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="time" className="flex items-center gap-2">
                <Calendar className="h-4 w-4" />
                Heure
              </Label>
              <Input
                id="time"
                name="time"
                type="time"
                value={formData.time}
                onChange={handleChange}
                required
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="guests" className="flex items-center gap-2">
                <Users className="h-4 w-4" />
                Nombre de personnes
              </Label>
              <select
                id="guests"
                name="guests"
                value={formData.guests}
                onChange={handleChange}
                required
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              >
                {Array.from({ length: 12 }, (_, i) => i + 1).map((num) => (
                  <option key={num} value={num}>
                    {num} {num === 1 ? 'personne' : 'personnes'}
                  </option>
                ))}
              </select>
              {parseInt(formData.guests) >= 8 && (
                <p className="text-sm text-orange-600 font-semibold">
                  ⚠️ Pour les groupes de 8+ personnes, réservation obligatoire 48h à l'avance
                </p>
              )}
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="name">Nom complet *</Label>
            <Input
              id="name"
              name="name"
              value={formData.name}
              onChange={handleChange}
              required
              placeholder="Votre nom"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-2">
              <Label htmlFor="email" className="flex items-center gap-2">
                <Mail className="h-4 w-4" />
                Email *
              </Label>
              <Input
                id="email"
                name="email"
                type="email"
                value={formData.email}
                onChange={handleChange}
                required
                placeholder="votre@email.com"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="phone" className="flex items-center gap-2">
                <Phone className="h-4 w-4" />
                Téléphone *
              </Label>
              <Input
                id="phone"
                name="phone"
                type="tel"
                value={formData.phone}
                onChange={handleChange}
                required
                placeholder="01 23 45 67 89"
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="notes">Notes ou demandes spéciales</Label>
            <Textarea
              id="notes"
              name="notes"
              value={formData.notes}
              onChange={handleChange}
              placeholder="Allergies, anniversaire, demande de table en terrasse..."
              rows={4}
            />
          </div>

          <div className="bg-yellow-50 border-2 border-yellow-300 rounded-lg p-4">
            <p className="text-sm text-orange-800">
              <strong>💡 Rappel :</strong> Pour le brunch du dimanche, réservez à l'avance car c'est très demandé !
              Annulation gratuite jusqu'à 24h avant.
            </p>
          </div>

          <Button
            type="submit"
            size="lg"
            className="w-full bg-primary hover:bg-primary/90 text-lg py-6"
            disabled={isSubmitting}
          >
            {isSubmitting ? 'Envoi en cours...' : 'Confirmer la réservation'}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}

