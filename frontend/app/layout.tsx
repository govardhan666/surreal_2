import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'IPulse Studio - AI-Powered Programmable IP Ecosystem',
  description: 'Create, protect, and monetize intellectual property in the age of AI. Built on Story Protocol.',
  keywords: ['IP', 'blockchain', 'AI', 'Story Protocol', 'NFT', 'intellectual property'],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className={inter.className}>
        {children}
      </body>
    </html>
  );
}
