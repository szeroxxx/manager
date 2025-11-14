/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  images: {
    unoptimized: true,
  },
  // Use environment variables from build args
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://72.61.173.90:5000',
    NEXT_PUBLIC_API_VERSION: process.env.NEXT_PUBLIC_API_VERSION || '/api',
    NEXT_PUBLIC_APP_NAME: process.env.NEXT_PUBLIC_APP_NAME || 'Company Management System',
  },
  // Ensure proper transpilation
  transpilePackages: [],
  // Disable features that might cause issues in Docker
  experimental: {
    // Keep empty to avoid experimental issues
  },
};

module.exports = nextConfig;