export interface MenuItem {
  id: string;
  name: string;
  description: string;
  price: number;
  category: string;
  vegetarian?: boolean;
  vegan?: boolean;
  spicy?: number; // 0-3
}

export interface MenuCategory {
  id: string;
  name: string;
  items: MenuItem[];
}

export interface OpeningHours {
  day: string;
  lunch?: string;
  dinner?: string;
  closed?: boolean;
}

export interface RestaurantInfo {
  name: string;
  address: string;
  phone: string;
  email: string;
  website: string;
  socialMedia: {
    instagram?: string;
    facebook?: string;
    tiktok?: string;
  };
}

