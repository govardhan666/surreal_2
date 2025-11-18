import { ethers } from 'ethers';

export type Network = 'mainnet' | 'testnet' | 'local';

export interface IPulseConfig {
  privateKey?: string;
  signer?: ethers.Signer;
  network?: Network;
  rpcUrl?: string;
  storyProtocolKey?: string;
  aiConfig?: AIConfig;
  contractAddresses?: ContractAddresses;
}

export interface AIConfig {
  openaiApiKey?: string;
  stabilityApiKey?: string;
  runwayApiKey?: string;
  huggingFaceApiKey?: string;
}

export interface ContractAddresses {
  marketplace?: string;
  royaltyDistributor?: string;
  derivativeTracker?: string;
}

export interface IPAsset {
  ipId: string;
  owner: string;
  name: string;
  description: string;
  contentUrl: string;
  metadata: Record<string, any>;
  createdAt: number;
  tokenId?: string;
}

export interface GenerateAIParams {
  type: 'image' | 'music' | 'video' | 'text';
  prompt: string;
  options?: {
    width?: number;
    height?: number;
    duration?: number;
    style?: string;
    model?: string;
  };
}

export interface AIGenerationResult {
  url: string;
  type: string;
  metadata: Record<string, any>;
  cost: number;
}

export interface RegisterIPParams {
  name: string;
  description: string;
  contentUrl: string;
  creator: string;
  metadata?: Record<string, any>;
}

export interface License {
  licenseId: string;
  ipId: string;
  licenseType: 'commercial' | 'non-commercial' | 'derivative';
  royaltyPercentage: number;
  licensee?: string;
  duration?: number;
  isActive: boolean;
}

export interface CreateLicenseParams {
  ipId: string;
  licenseType: 'commercial' | 'non-commercial' | 'derivative';
  royaltyPercentage: number;
  duration?: number;
  price?: bigint;
}

export interface RoyaltySplit {
  recipient: string;
  percentage: number;
}

export interface DerivativeWork {
  derivativeId: string;
  originalId: string;
  creator: string;
  derivativeType: 'remix' | 'adaptation' | 'translation' | 'compilation' | 'transformation' | 'inspired';
  metadata: string;
  createdAt: number;
  generationLevel: number;
  isVerified: boolean;
}

export interface MarketplaceListing {
  listingId: string;
  seller: string;
  ipAsset: string;
  tokenId: string;
  price: bigint;
  listingType: 'sale' | 'license';
  status: 'active' | 'sold' | 'cancelled';
  createdAt: number;
  expiresAt: number;
}

export interface IPAnalytics {
  ipId: string;
  totalRevenue: bigint;
  derivativeCount: number;
  licenseCount: number;
  estimatedValue: bigint;
  trendScore: number;
  popularityRank?: number;
}

export interface ValuationMetrics {
  currentValue: bigint;
  projectedValue: bigint;
  confidence: number;
  factors: {
    derivativeActivity: number;
    marketDemand: number;
    creatorReputation: number;
    contentQuality: number;
  };
}
