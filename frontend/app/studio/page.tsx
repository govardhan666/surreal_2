'use client';

import { useState } from 'react';
import { Sparkles, Image, Music, Video, FileText, Wand2 } from 'lucide-react';

export default function StudioPage() {
  const [selectedType, setSelectedType] = useState<'image' | 'music' | 'video' | 'text'>('image');
  const [prompt, setPrompt] = useState('');
  const [isGenerating, setIsGenerating] = useState(false);

  const mediaTypes = [
    { id: 'image' as const, label: 'Image', icon: Image, description: 'Generate unique artwork' },
    { id: 'music' as const, label: 'Music', icon: Music, description: 'Compose original music' },
    { id: 'video' as const, label: 'Video', icon: Video, description: 'Create video content' },
    { id: 'text' as const, label: 'Story', icon: FileText, description: 'Write compelling stories' },
  ];

  const handleGenerate = async () => {
    if (!prompt.trim()) return;

    setIsGenerating(true);

    // Simulate AI generation
    await new Promise(resolve => setTimeout(resolve, 3000));

    setIsGenerating(false);
    alert(`Generated ${selectedType} from prompt: "${prompt}"`);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-black text-white">
      {/* Header */}
      <header className="border-b border-purple-500/20 bg-black/30 backdrop-blur-lg">
        <div className="max-w-7xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Sparkles className="w-8 h-8 text-purple-400" />
            <h1 className="text-2xl font-bold">AI Studio</h1>
          </div>
          <nav className="flex gap-4">
            <a href="/" className="px-4 py-2 hover:text-purple-400 transition">Home</a>
            <a href="/marketplace" className="px-4 py-2 hover:text-purple-400 transition">Marketplace</a>
            <a href="/dashboard" className="px-4 py-2 hover:text-purple-400 transition">Dashboard</a>
          </nav>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 py-12">
        <div className="text-center mb-12">
          <h2 className="text-5xl font-bold mb-4 gradient-text">
            Create with AI
          </h2>
          <p className="text-xl text-gray-400">
            Generate unique IP assets using state-of-the-art AI models
          </p>
        </div>

        <div className="grid lg:grid-cols-2 gap-8">
          {/* Left Panel - Input */}
          <div className="glass-panel p-8">
            <h3 className="text-2xl font-semibold mb-6">What do you want to create?</h3>

            {/* Media Type Selection */}
            <div className="grid grid-cols-2 gap-4 mb-6">
              {mediaTypes.map((type) => (
                <button
                  key={type.id}
                  onClick={() => setSelectedType(type.id)}
                  className={`p-4 rounded-lg border-2 transition-all ${
                    selectedType === type.id
                      ? 'border-purple-500 bg-purple-500/20'
                      : 'border-purple-500/20 hover:border-purple-500/40'
                  }`}
                >
                  <type.icon className="w-8 h-8 mb-2 mx-auto" />
                  <div className="font-semibold">{type.label}</div>
                  <div className="text-sm text-gray-400">{type.description}</div>
                </button>
              ))}
            </div>

            {/* Prompt Input */}
            <div className="mb-6">
              <label className="block text-sm font-medium mb-2">
                Describe your vision
              </label>
              <textarea
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
                placeholder={`E.g., "${getPlaceholder(selectedType)}"`}
                className="w-full h-32 px-4 py-3 bg-black/30 border border-purple-500/30 rounded-lg focus:border-purple-500 focus:outline-none resize-none"
              />
            </div>

            {/* Advanced Options */}
            <details className="mb-6">
              <summary className="cursor-pointer text-purple-400 hover:text-purple-300 mb-4">
                Advanced Options
              </summary>
              <div className="space-y-4 pl-4">
                <div>
                  <label className="block text-sm mb-2">Style</label>
                  <select className="w-full px-4 py-2 bg-black/30 border border-purple-500/30 rounded-lg">
                    <option>Realistic</option>
                    <option>Artistic</option>
                    <option>Abstract</option>
                    <option>Cinematic</option>
                  </select>
                </div>
                {selectedType === 'image' && (
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <label className="block text-sm mb-2">Width</label>
                      <input type="number" defaultValue={1024} className="w-full px-4 py-2 bg-black/30 border border-purple-500/30 rounded-lg" />
                    </div>
                    <div>
                      <label className="block text-sm mb-2">Height</label>
                      <input type="number" defaultValue={1024} className="w-full px-4 py-2 bg-black/30 border border-purple-500/30 rounded-lg" />
                    </div>
                  </div>
                )}
              </div>
            </details>

            {/* Generate Button */}
            <button
              onClick={handleGenerate}
              disabled={!prompt.trim() || isGenerating}
              className="w-full py-4 rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 hover:from-purple-700 hover:to-blue-700 font-semibold transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              {isGenerating ? (
                <>
                  <div className="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                  Generating...
                </>
              ) : (
                <>
                  <Wand2 className="w-5 h-5" />
                  Generate & Register as IP
                </>
              )}
            </button>
          </div>

          {/* Right Panel - Preview */}
          <div className="glass-panel p-8">
            <h3 className="text-2xl font-semibold mb-6">Preview</h3>

            <div className="aspect-square bg-gradient-to-br from-purple-900/50 to-blue-900/50 rounded-lg border-2 border-dashed border-purple-500/30 flex items-center justify-center mb-6">
              {isGenerating ? (
                <div className="text-center">
                  <div className="w-16 h-16 border-4 border-purple-500/20 border-t-purple-500 rounded-full animate-spin mx-auto mb-4"></div>
                  <p className="text-gray-400">Creating magic...</p>
                </div>
              ) : (
                <div className="text-center text-gray-500">
                  <Sparkles className="w-16 h-16 mx-auto mb-4 opacity-50" />
                  <p>Your creation will appear here</p>
                </div>
              )}
            </div>

            {/* IP Registration Info */}
            <div className="space-y-4">
              <h4 className="font-semibold">Auto-Registration</h4>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between p-3 bg-black/30 rounded-lg">
                  <span className="text-gray-400">Blockchain</span>
                  <span className="font-semibold">Story Protocol</span>
                </div>
                <div className="flex justify-between p-3 bg-black/30 rounded-lg">
                  <span className="text-gray-400">Storage</span>
                  <span className="font-semibold">IPFS</span>
                </div>
                <div className="flex justify-between p-3 bg-black/30 rounded-lg">
                  <span className="text-gray-400">License Type</span>
                  <span className="font-semibold">Commercial + Derivatives</span>
                </div>
                <div className="flex justify-between p-3 bg-black/30 rounded-lg">
                  <span className="text-gray-400">Royalty</span>
                  <span className="font-semibold">10%</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Recent Creations */}
        <div className="mt-12">
          <h3 className="text-2xl font-semibold mb-6">Recent Creations</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="glass-panel p-4">
                <div className="aspect-square bg-gradient-to-br from-purple-900/50 to-blue-900/50 rounded-lg mb-3"></div>
                <p className="text-sm font-medium truncate">Creation #{i}</p>
                <p className="text-xs text-gray-400">2 hours ago</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function getPlaceholder(type: string): string {
  const placeholders = {
    image: 'A futuristic city with flying cars at sunset',
    music: 'Upbeat electronic music with ambient undertones',
    video: 'Time-lapse of a blooming flower in a magical forest',
    text: 'A story about an AI that discovers creativity',
  };
  return placeholders[type as keyof typeof placeholders] || '';
}
