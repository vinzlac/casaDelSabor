'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import MenuItem from './MenuItem';

interface MenuItemData {
  name: string;
  description: string;
  price: number | string;
  emoji?: string;
  vegetarian?: boolean;
  vegan?: boolean;
  spicy?: number;
}

interface MenuCategoryProps {
  title: string;
  emoji: string;
  items: MenuItemData[];
}

export default function MenuCategory({ title, emoji, items }: MenuCategoryProps) {
  return (
    <Card className="mb-8 border-2 border-primary/20 shadow-lg">
      <CardHeader className="bg-gradient-to-r from-red-500 via-orange-500 to-yellow-500 text-white rounded-t-lg">
        <CardTitle className="text-3xl flex items-center gap-3">
          <span className="text-4xl">{emoji}</span>
          {title}
        </CardTitle>
      </CardHeader>
      <CardContent className="p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {items.map((item, index) => (
            <MenuItem key={index} {...item} />
          ))}
        </div>
      </CardContent>
    </Card>
  );
}

