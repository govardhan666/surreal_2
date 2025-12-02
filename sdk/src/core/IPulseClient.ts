import { ethers } from 'ethers';
import { IPAssetManager } from './IPAssetManager';
import { AIEngine } from '../ai/AIEngine';
import { LicensingManager } from '../licensing/LicensingManager';
import { RoyaltyManager } from '../licensing/RoyaltyManager';
import { AnalyticsEngine } from '../analytics/AnalyticsEngine';
import { MarketplaceClient } from './MarketplaceClient';
import { IPulseConfig, Network } from '../types';

/**
 * Main client for interacting with IPulse Studio
 *
 * @example
 * ```typescript
 * const ipulse = new IPulseClient({
 *   privateKey: 'your-private-key',
 *   network: 'testnet',
 *   storyProtocolKey: 'your-api-key'
 * });
 *
 * // Generate AI content and register as IP
 * const ipAsset = await ipulse.ai.generateAndRegister({
 *   type: 'image',
 *   prompt: 'A futuristic cityscape',
 *   creator: walletAddress
 * });
 * ```
 */
export class IPulseClient {
  public readonly provider: ethers.Provider;
  public readonly signer: ethers.Signer;
  public readonly network: Network;

  // Sub-modules
  public readonly ipAssets: IPAssetManager;
  public readonly ai: AIEngine;
  public readonly licensing: LicensingManager;
  public readonly royalties: RoyaltyManager;
  public readonly analytics: AnalyticsEngine;
  public readonly marketplace: MarketplaceClient;

  /**
   * Create a new IPulse client instance
   */
  constructor(config: IPulseConfig) {
    this.network = config.network || 'testnet';

    // Initialize provider
    const rpcUrl = this._getRpcUrl(this.network, config.rpcUrl);
    this.provider = new ethers.JsonRpcProvider(rpcUrl);

    // Initialize signer
    if (config.privateKey) {
      this.signer = new ethers.Wallet(config.privateKey, this.provider);
    } else if (config.signer) {
      this.signer = config.signer;
    } else {
      throw new Error('Either privateKey or signer must be provided');
    }

    // Initialize sub-modules
    this.ipAssets = new IPAssetManager(this);
    this.ai = new AIEngine(this, config.aiConfig);
    this.licensing = new LicensingManager(this);
    this.royalties = new RoyaltyManager(this);
    this.analytics = new AnalyticsEngine(this);
    this.marketplace = new MarketplaceClient(this);
  }

  /**
   * Get RPC URL for the specified network
   */
  private _getRpcUrl(network: Network, customRpcUrl?: string): string {
    if (customRpcUrl) return customRpcUrl;

    const rpcUrls: Record<Network, string> = {
      mainnet: 'https://rpc.story.foundation',
      testnet: 'https://rpc.odyssey.storyrpc.io',
      local: 'http://localhost:8545',
    };

    return rpcUrls[network];
  }

  /**
   * Get the current wallet address
   */
  async getAddress(): Promise<string> {
    return await this.signer.getAddress();
  }

  /**
   * Get the current network chain ID
   */
  async getChainId(): Promise<number> {
    const network = await this.provider.getNetwork();
    return Number(network.chainId);
  }

  /**
   * Get wallet balance
   */
  async getBalance(): Promise<bigint> {
    const address = await this.getAddress();
    return await this.provider.getBalance(address);
  }

  /**
   * Quick start: Generate AI content and register as IP in one call
   */
  async quickStart(params: {
    type: 'image' | 'music' | 'video' | 'text';
    prompt: string;
    licenseType?: 'commercial' | 'non-commercial' | 'derivative';
    royaltyPercentage?: number;
  }) {
    console.log('🚀 IPulse Quick Start');
    console.log('📝 Generating AI content...');

    // Generate AI content
    const content = await this.ai.generate({
      type: params.type,
      prompt: params.prompt,
    });

    console.log('✅ Content generated');
    console.log('📦 Registering as IP asset...');

    // Register as IP asset
    const ipAsset = await this.ipAssets.register({
      name: `AI Generated ${params.type}`,
      description: `Generated from prompt: ${params.prompt}`,
      contentUrl: content.url,
      creator: await this.getAddress(),
    });

    console.log('✅ IP asset registered:', ipAsset.ipId);

    // Configure licensing if specified
    if (params.licenseType) {
      console.log('⚖️ Configuring license...');

      await this.licensing.createLicense({
        ipId: ipAsset.ipId,
        licenseType: params.licenseType,
        royaltyPercentage: params.royaltyPercentage || 10,
      });

      console.log('✅ License configured');
    }

    console.log('🎉 Quick start complete!');

    return {
      ipAsset,
      content,
    };
  }
}
