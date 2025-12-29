import { Metadata } from 'next';
import HeroSection from '@/components/sections/HeroSection';
import MenuSection from '@/components/sections/MenuSection';
import HoursSection from '@/components/sections/HoursSection';
import AboutSection from '@/components/sections/AboutSection';
import ReservationSection from '@/components/sections/ReservationSection';

export const metadata: Metadata = {
  title: "Casa del Sabor - Restaurant Mexicain Authentique à Paris",
  description: "Restaurant mexicain authentique à Paris. Découvrez nos spécialités mexicaines, brunch du dimanche, soirées Mariachi. Ambiance festive garantie !",
  openGraph: {
    title: "Casa del Sabor - Restaurant Mexicain à Paris",
    description: "Restaurant mexicain authentique avec ambiance festive. Spécialités mexicaines et brunch du dimanche.",
    type: "website",
  },
};

export default function Home() {
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "Restaurant",
    "name": "Casa del Sabor",
    "image": "https://www.casadelsabor.fr/og-image.jpg",
    "address": {
      "@type": "PostalAddress",
      "streetAddress": "42 Rue des Épices",
      "addressLocality": "Paris",
      "postalCode": "75011",
      "addressCountry": "FR"
    },
    "geo": {
      "@type": "GeoCoordinates",
      "latitude": 48.8522,
      "longitude": 2.3694
    },
    "url": "https://www.casadelsabor.fr",
    "telephone": "+33142551234",
    "priceRange": "€€",
    "servesCuisine": "Mexican",
    "openingHoursSpecification": [
      {
        "@type": "OpeningHoursSpecification",
        "dayOfWeek": ["Tuesday", "Wednesday", "Thursday"],
        "opens": "12:00",
        "closes": "14:30"
      },
      {
        "@type": "OpeningHoursSpecification",
        "dayOfWeek": ["Tuesday", "Wednesday", "Thursday"],
        "opens": "19:00",
        "closes": "22:30"
      },
      {
        "@type": "OpeningHoursSpecification",
        "dayOfWeek": ["Friday"],
        "opens": "12:00",
        "closes": "14:30"
      },
      {
        "@type": "OpeningHoursSpecification",
        "dayOfWeek": ["Friday"],
        "opens": "19:00",
        "closes": "23:00"
      },
      {
        "@type": "OpeningHoursSpecification",
        "dayOfWeek": ["Saturday"],
        "opens": "12:00",
        "closes": "15:00"
      },
      {
        "@type": "OpeningHoursSpecification",
        "dayOfWeek": ["Saturday"],
        "opens": "19:00",
        "closes": "23:00"
      },
      {
        "@type": "OpeningHoursSpecification",
        "dayOfWeek": ["Sunday"],
        "opens": "12:00",
        "closes": "16:00"
      }
    ]
  };

  return (
    <main>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }}
      />
      <HeroSection />
      <MenuSection />
      <HoursSection />
      <AboutSection />
      <ReservationSection />
    </main>
  );
}
