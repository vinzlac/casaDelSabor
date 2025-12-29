import { Metadata } from 'next';
import MenuCategory from '@/components/menu/MenuCategory';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';

export const metadata: Metadata = {
  title: 'Menu - Casa del Sabor',
  description: 'Découvrez notre menu complet avec toutes nos spécialités mexicaines authentiques',
};

const menuData = {
  entrees: {
    title: 'Entrées / Antojitos',
    emoji: '🌮',
    items: [
      {
        name: 'Guacamole Fresco',
        description: 'Avocat frais écrasé avec tomates, oignons, coriandre, piment jalapeño et citron vert. Servi avec chips de maïs maison.',
        price: '8€',
        emoji: '🥑',
        vegetarian: true,
      },
      {
        name: 'Nachos Supremos',
        description: 'Chips de maïs garnies de fromage fondu, haricots noirs, crème fraîche, pico de gallo et jalapeños.',
        price: '10€ - 14€',
        emoji: '🌽',
      },
      {
        name: 'Quesadillas',
        description: 'Tortilla de blé garnie de fromage fondu.',
        price: '8€ - 12€',
        emoji: '🧀',
        vegetarian: true,
      },
      {
        name: 'Elotes (Maïs grillé)',
        description: 'Épi de maïs grillé avec mayonnaise, fromage cotija, piment et citron vert.',
        price: '6€',
        emoji: '🌽',
        vegetarian: true,
      },
    ],
  },
  plats: {
    title: 'Plats Principaux / Platos Fuertes',
    emoji: '🍽️',
    items: [
      {
        name: 'Tacos al Pastor',
        description: 'Porc mariné à l\'achiote, ananas, oignon, coriandre (3 pièces)',
        price: '12€',
        emoji: '🌮',
        spicy: 1,
      },
      {
        name: 'Tacos de Carnitas',
        description: 'Porc confit effiloché (3 pièces)',
        price: '12€',
        emoji: '🌮',
      },
      {
        name: 'Tacos de Pollo',
        description: 'Poulet grillé mariné (3 pièces)',
        price: '11€',
        emoji: '🌮',
      },
      {
        name: 'Tacos de Barbacoa',
        description: 'Bœuf braisé lentement (3 pièces)',
        price: '13€',
        emoji: '🌮',
      },
      {
        name: 'Tacos Vegetarianos',
        description: 'Champignons, poivrons, oignons grillés (3 pièces)',
        price: '10€',
        emoji: '🌮',
        vegetarian: true,
      },
      {
        name: 'Burrito Supremo',
        description: 'Grande tortilla de blé garnie de riz, haricots noirs, fromage, crème, laitue, pico de gallo et votre choix de protéine.',
        price: '13€ - 15€',
        emoji: '🌯',
      },
      {
        name: 'Enchiladas Verdes',
        description: 'Tortillas roulées garnies, nappées de sauce tomatillo verte, poulet (3 pièces)',
        price: '15€',
        emoji: '🍽️',
      },
      {
        name: 'Enchiladas Rojas',
        description: 'Sauce piment rouge, bœuf (3 pièces)',
        price: '16€',
        emoji: '🍽️',
        spicy: 2,
      },
      {
        name: 'Fajitas',
        description: 'Viande grillée avec poivrons et oignons, servie sur plaque chaude avec tortillas, guacamole, crème et pico de gallo.',
        price: '18€ - 22€',
        emoji: '🔥',
      },
      {
        name: 'Mole Poblano',
        description: 'Poulet nappé de notre sauce mole maison (chocolat, piments, épices). Servi avec riz et tortillas.',
        price: '18€',
        emoji: '🍗',
        spicy: 2,
      },
    ],
  },
  salades: {
    title: 'Salades / Ensaladas',
    emoji: '🥗',
    items: [
      {
        name: 'Salade Mexicaine',
        description: 'Laitue, tomates, maïs, haricots noirs, avocat, fromage, tortilla chips, vinaigrette citron-coriandre.',
        price: '10€ - 14€',
        emoji: '🥗',
        vegetarian: true,
      },
      {
        name: 'Salade César Mexicaine',
        description: 'Notre version avec piment chipotle dans la sauce, croûtons au maïs.',
        price: '12€',
        emoji: '🥗',
      },
    ],
  },
  desserts: {
    title: 'Desserts / Postres',
    emoji: '🍰',
    items: [
      {
        name: 'Churros con Chocolate',
        description: 'Beignets mexicains croustillants avec sauce chocolat chaud.',
        price: '7€',
        emoji: '🍫',
        vegetarian: true,
      },
      {
        name: 'Flan de Caramelo',
        description: 'Flan traditionnel au caramel.',
        price: '6€',
        emoji: '🍮',
        vegetarian: true,
      },
      {
        name: 'Tres Leches',
        description: 'Gâteau imbibé de trois laits (lait concentré, lait évaporé, crème).',
        price: '7€',
        emoji: '🍰',
        vegetarian: true,
      },
    ],
  },
  boissons: {
    title: 'Boissons / Bebidas',
    emoji: '🍹',
    items: [
      {
        name: 'Agua Fresca',
        description: 'Hibiscus, Tamarindo, Horchata',
        price: '4€',
        emoji: '🥤',
        vegetarian: true,
      },
      {
        name: 'Margarita Classique',
        description: 'Tequila, citron vert, triple sec',
        price: '9€',
        emoji: '🍸',
      },
      {
        name: 'Margarita Fruits',
        description: 'Mangue, fraise, passion',
        price: '10€',
        emoji: '🍹',
      },
      {
        name: 'Paloma',
        description: 'Tequila, pamplemousse',
        price: '9€',
        emoji: '🍹',
      },
    ],
  },
};

export default function MenuPage() {
  return (
    <main className="min-h-screen bg-gradient-to-b from-white via-orange-50 to-yellow-50 py-12 relative overflow-hidden">
      {/* Image de fond principale - Cuisine mexicaine colorée */}
      <div className="fixed inset-0 z-0">
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat"
          style={{
            backgroundImage: 'url(https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=1920&q=80&auto=format&fit=crop)',
          }}
        />
        {/* Overlay coloré pour garder la lisibilité avec couleurs mexicaines */}
        <div className="absolute inset-0 bg-gradient-to-b from-white/70 via-orange-50/75 to-yellow-50/70" />
        {/* Pattern mexicain par-dessus pour effet festif */}
        <div className="absolute inset-0 bg-mexican-stripes opacity-25" />
      </div>
      
      {/* Images décoratives flottantes de plats mexicains */}
      <div className="fixed inset-0 z-0 pointer-events-none overflow-hidden">
        {/* Tacos colorés en haut à droite */}
        <div 
          className="absolute top-20 right-10 w-64 h-64 rounded-full opacity-20 bg-cover bg-center blur-[2px]"
          style={{
            backgroundImage: 'url(https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80&auto=format&fit=crop)',
          }}
        />
        {/* Guacamole frais en bas à gauche */}
        <div 
          className="absolute bottom-20 left-10 w-48 h-48 rounded-full opacity-20 bg-cover bg-center blur-[2px]"
          style={{
            backgroundImage: 'url(https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&q=80&auto=format&fit=crop)',
          }}
        />
        {/* Burrito au centre gauche */}
        <div 
          className="absolute top-1/2 left-1/4 w-40 h-40 rounded-full opacity-18 bg-cover bg-center blur-[2px]"
          style={{
            backgroundImage: 'url(https://images.unsplash.com/photo-1565299585323-38174c3a5e0a?w=800&q=80&auto=format&fit=crop)',
          }}
        />
        {/* Enchiladas en bas à droite */}
        <div 
          className="absolute bottom-32 right-1/4 w-56 h-56 rounded-full opacity-15 bg-cover bg-center blur-[2px]"
          style={{
            backgroundImage: 'url(https://images.unsplash.com/photo-1574340639900-19b4848b1a0a?w=800&q=80&auto=format&fit=crop)',
          }}
        />
        {/* Chiles et épices mexicaines */}
        <div 
          className="absolute top-1/3 right-1/3 w-36 h-36 rounded-full opacity-12 bg-cover bg-center blur-[2px]"
          style={{
            backgroundImage: 'url(https://images.unsplash.com/photo-1596797038530-2c107229654b?w=800&q=80&auto=format&fit=crop)',
          }}
        />
      </div>
      
      <div className="max-w-7xl mx-auto px-4 py-12 relative z-10">
        <div className="text-center mb-12">
          <h1 className="text-6xl font-bold text-primary mb-4">Notre Menu</h1>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Découvrez toutes nos spécialités mexicaines authentiques
          </p>
        </div>

        <Tabs defaultValue="all" className="w-full">
          <TabsList className="grid w-full grid-cols-3 lg:grid-cols-6 mb-8">
            <TabsTrigger value="all">Tout</TabsTrigger>
            <TabsTrigger value="entrees">Entrées</TabsTrigger>
            <TabsTrigger value="plats">Plats</TabsTrigger>
            <TabsTrigger value="salades">Salades</TabsTrigger>
            <TabsTrigger value="desserts">Desserts</TabsTrigger>
            <TabsTrigger value="boissons">Boissons</TabsTrigger>
          </TabsList>

          <TabsContent value="all" className="space-y-8">
            <MenuCategory {...menuData.entrees} />
            <MenuCategory {...menuData.plats} />
            <MenuCategory {...menuData.salades} />
            <MenuCategory {...menuData.desserts} />
            <MenuCategory {...menuData.boissons} />
          </TabsContent>

          <TabsContent value="entrees">
            <MenuCategory {...menuData.entrees} />
          </TabsContent>

          <TabsContent value="plats">
            <MenuCategory {...menuData.plats} />
          </TabsContent>

          <TabsContent value="salades">
            <MenuCategory {...menuData.salades} />
          </TabsContent>

          <TabsContent value="desserts">
            <MenuCategory {...menuData.desserts} />
          </TabsContent>

          <TabsContent value="boissons">
            <MenuCategory {...menuData.boissons} />
          </TabsContent>
        </Tabs>

        <div className="mt-12 p-6 bg-yellow-100 rounded-lg border-2 border-yellow-300 text-center">
          <p className="text-lg font-semibold text-orange-800">
            📋 Formules Midi disponibles du mardi au vendredi (12h-14h30)
          </p>
          <p className="text-gray-700 mt-2">
            Formule Express 15€ | Formule Complète 20€
          </p>
        </div>
      </div>
    </main>
  );
}

