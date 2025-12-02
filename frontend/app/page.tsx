import Link from 'next/link';
import { ArrowRight, Sparkles, Shield, TrendingUp, Zap } from 'lucide-react';

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-black text-white">
      {/* Hero Section */}
      <section className="relative overflow-hidden py-20 px-4">
        <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-20"></div>

        <div className="relative max-w-6xl mx-auto text-center">
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-purple-500/20 border border-purple-500/30 mb-8">
            <Sparkles className="w-4 h-4" />
            <span className="text-sm">Built for Surreal World Assets Buildathon</span>
          </div>

          <h1 className="text-6xl md:text-8xl font-bold mb-6 bg-clip-text text-transparent bg-gradient-to-r from-purple-400 to-blue-400">
            IPulse Studio
          </h1>

          <p className="text-xl md:text-2xl text-gray-300 mb-4">
            The AI-Powered Programmable IP Ecosystem
          </p>

          <p className="text-lg text-gray-400 max-w-3xl mx-auto mb-12">
            Create, protect, and monetize intellectual property in the age of AI.
            Built on Story Protocol with cutting-edge AI integration.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/studio"
              className="inline-flex items-center gap-2 px-8 py-4 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700 font-semibold transition-all transform hover:scale-105"
            >
              Launch AI Studio
              <ArrowRight className="w-5 h-5" />
            </Link>

            <Link
              href="/marketplace"
              className="inline-flex items-center gap-2 px-8 py-4 rounded-lg border-2 border-purple-500/50 hover:border-purple-500 font-semibold transition-all"
            >
              Explore Marketplace
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 px-4 bg-black/30">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-12">
            Revolutionize IP Management
          </h2>

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {features.map((feature, index) => (
              <div
                key={index}
                className="p-6 rounded-xl bg-gradient-to-br from-purple-900/50 to-blue-900/50 border border-purple-500/20 hover:border-purple-500/40 transition-all"
              >
                <div className="w-12 h-12 rounded-lg bg-purple-500/20 flex items-center justify-center mb-4">
                  {feature.icon}
                </div>
                <h3 className="text-xl font-semibold mb-2">{feature.title}</h3>
                <p className="text-gray-400">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-20 px-4">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-12">
            How It Works
          </h2>

          <div className="grid md:grid-cols-3 gap-8">
            {steps.map((step, index) => (
              <div key={index} className="text-center">
                <div className="w-16 h-16 rounded-full bg-gradient-to-r from-purple-600 to-blue-600 flex items-center justify-center text-2xl font-bold mx-auto mb-4">
                  {index + 1}
                </div>
                <h3 className="text-xl font-semibold mb-2">{step.title}</h3>
                <p className="text-gray-400">{step.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-20 px-4 bg-black/30">
        <div className="max-w-6xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
          {stats.map((stat, index) => (
            <div key={index}>
              <div className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-purple-400 to-blue-400 mb-2">
                {stat.value}
              </div>
              <div className="text-gray-400">{stat.label}</div>
            </div>
          ))}
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 px-4">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-4xl md:text-5xl font-bold mb-6">
            Ready to Create Programmable IP?
          </h2>
          <p className="text-xl text-gray-400 mb-8">
            Join the future of intellectual property management powered by AI and blockchain
          </p>
          <Link
            href="/studio"
            className="inline-flex items-center gap-2 px-8 py-4 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700 font-semibold transition-all transform hover:scale-105"
          >
            Get Started Now
            <ArrowRight className="w-5 h-5" />
          </Link>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-8 px-4 border-t border-purple-500/20">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row justify-between items-center gap-4 text-gray-400">
          <div>
            Built with ❤️ for Surreal World Assets Buildathon
          </div>
          <div className="flex gap-6">
            <Link href="/docs" className="hover:text-white transition">Docs</Link>
            <Link href="/github" className="hover:text-white transition">GitHub</Link>
            <Link href="/discord" className="hover:text-white transition">Discord</Link>
          </div>
        </div>
      </footer>
    </div>
  );
}

const features = [
  {
    icon: <Sparkles className="w-6 h-6 text-purple-400" />,
    title: 'AI Generation',
    description: 'Create unique IP assets using cutting-edge AI models for images, music, and video.',
  },
  {
    icon: <Shield className="w-6 h-6 text-blue-400" />,
    title: 'IP Protection',
    description: 'Register and protect your IP on Story Protocol with immutable on-chain records.',
  },
  {
    icon: <TrendingUp className="w-6 h-6 text-green-400" />,
    title: 'Smart Licensing',
    description: 'Programmable licensing terms with automated royalty distribution.',
  },
  {
    icon: <Zap className="w-6 h-6 text-yellow-400" />,
    title: 'Auto Royalties',
    description: 'Earn automatically from all derivative works and commercial uses.',
  },
];

const steps = [
  {
    title: 'Create with AI',
    description: 'Use our AI studio to generate original IP assets from text prompts.',
  },
  {
    title: 'Register on-chain',
    description: 'Automatically register your IP on Story Protocol with full provenance.',
  },
  {
    title: 'License & Earn',
    description: 'Set licensing terms and earn royalties from every use and derivative.',
  },
];

const stats = [
  { value: '$35K', label: 'Prize Pool' },
  { value: '7', label: 'Tracks Covered' },
  { value: '100%', label: 'On-Chain' },
  { value: '∞', label: 'Possibilities' },
];
