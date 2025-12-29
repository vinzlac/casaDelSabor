'use client';

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';

interface MenuItemProps {
  name: string;
  description: string;
  price: number | string;
  emoji?: string;
  vegetarian?: boolean;
  vegan?: boolean;
  spicy?: number;
}

export default function MenuItem({
  name,
  description,
  price,
  emoji,
  vegetarian,
  vegan,
  spicy,
}: MenuItemProps) {
  return (
    <Card className="border-2 border-orange-200 hover:border-primary transition-all hover:shadow-lg">
      <CardHeader>
        <div className="flex items-start justify-between gap-2">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-1">
              {emoji && <span className="text-2xl">{emoji}</span>}
              <CardTitle className="text-lg text-primary">{name}</CardTitle>
            </div>
            <CardDescription className="text-sm">{description}</CardDescription>
          </div>
          <div className="text-right">
            <span className="text-2xl font-bold text-primary">{price}</span>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="flex flex-wrap gap-2">
          {vegetarian && (
            <Badge variant="outline" className="bg-green-50 text-green-700 border-green-300">
              🌱 Végétarien
            </Badge>
          )}
          {vegan && (
            <Badge variant="outline" className="bg-green-100 text-green-800 border-green-400">
              🌿 Vegan
            </Badge>
          )}
          {spicy !== undefined && spicy > 0 && (
            <Badge variant="outline" className="bg-red-50 text-red-700 border-red-300">
              {'🌶️'.repeat(spicy)} {spicy === 1 ? 'Doux' : spicy === 2 ? 'Moyen' : 'Fort'}
            </Badge>
          )}
        </div>
      </CardContent>
    </Card>
  );
}

