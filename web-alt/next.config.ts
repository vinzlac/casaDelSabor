import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  /* config options here */
  // Forcer Next.js à utiliser le répertoire web-alt comme répertoire de travail
  // pour éviter qu'il remonte dans l'arborescence à cause du package.json dans /Users/vinz/
  turbopack: {
    root: path.resolve(__dirname),
  },
};

export default nextConfig;
