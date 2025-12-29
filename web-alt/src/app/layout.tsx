import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import ChatbotWidget from "@/components/chatbot/ChatbotWidget";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Casa del Sabor - Restaurant Mexicain à Paris",
  description: "Découvrez la vraie cuisine mexicaine à Paris. Restaurant authentique avec ambiance festive, spécialités mexicaines et brunch du dimanche.",
  keywords: ["restaurant mexicain", "Paris", "cuisine mexicaine", "tacos", "brunch mexicain", "Bastille", "75011"],
  openGraph: {
    title: "Casa del Sabor - Restaurant Mexicain à Paris",
    description: "Découvrez la vraie cuisine mexicaine à Paris. Restaurant authentique avec ambiance festive.",
    type: "website",
    locale: "fr_FR",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="fr">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        {children}
        <ChatbotWidget />
      </body>
    </html>
  );
}
