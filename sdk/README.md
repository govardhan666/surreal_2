# @ipulse/sdk

Official TypeScript SDK for building on IPulse Studio and Story Protocol.

## Installation

```bash
npm install @ipulse/sdk
# or
yarn add @ipulse/sdk
# or
pnpm add @ipulse/sdk
```

## Quick Start

```typescript
import { IPulseClient } from '@ipulse/sdk';

// Initialize the client
const ipulse = new IPulseClient({
  privateKey: process.env.PRIVATE_KEY,
  network: 'testnet',
  storyProtocolKey: process.env.STORY_API_KEY,
  aiConfig: {
    openaiApiKey: process.env.OPENAI_API_KEY
  }
});

// Generate AI content and register as IP
const result = await ipulse.quickStart({
  type: 'image',
  prompt: 'A futuristic cityscape with flying cars',
  licenseType: 'commercial',
  royaltyPercentage: 10
});

console.log('IP Asset created:', result.ipAsset.ipId);
```

## Core Modules

### IPAssetManager

Manage IP assets on Story Protocol.

```typescript
// Register new IP asset
const ipAsset = await ipulse.ipAssets.register({
  name: 'My Artwork',
  description: 'A beautiful piece of art',
  contentUrl: 'ipfs://...',
  creator: walletAddress
});

// Get IP asset details
const details = await ipulse.ipAssets.get(ipAssetId);

// Transfer IP ownership
await ipulse.ipAssets.transfer({
  ipId: ipAssetId,
  to: newOwnerAddress
});
```

### AIEngine

Generate content using AI models.

```typescript
// Generate image
const image = await ipulse.ai.generate({
  type: 'image',
  prompt: 'A mystical forest at twilight',
  options: {
    width: 1024,
    height: 1024,
    style: 'realistic'
  }
});

// Generate music
const music = await ipulse.ai.generate({
  type: 'music',
  prompt: 'Upbeat electronic music with ambient undertones',
  options: {
    duration: 120 // seconds
  }
});

// Generate video
const video = await ipulse.ai.generate({
  type: 'video',
  prompt: 'Time-lapse of a blooming flower',
  options: {
    duration: 10,
    width: 1920,
    height: 1080
  }
});
```

### LicensingManager

Create and manage IP licenses.

```typescript
// Create a license
const license = await ipulse.licensing.createLicense({
  ipId: ipAssetId,
  licenseType: 'commercial',
  royaltyPercentage: 10,
  duration: 365 * 24 * 60 * 60 // 1 year in seconds
});

// Check if license is valid
const isValid = await ipulse.licensing.isLicenseValid(licenseId);

// Get license terms
const terms = await ipulse.licensing.getLicenseTerms(licenseId);
```

### RoyaltyManager

Configure and distribute royalties.

```typescript
// Configure royalty split
await ipulse.royalties.configure({
  ipId: ipAssetId,
  recipients: [creator1, creator2],
  percentages: [7000, 3000] // 70/30 split (in basis points)
});

// Register derivative work
await ipulse.royalties.registerDerivative({
  originalId: originalIPId,
  derivativeId: newIPId,
  royaltyPercentage: 1000 // 10%
});

// Distribute royalties
await ipulse.royalties.distribute({
  ipId: ipAssetId,
  amount: ethers.parseEther("1.0")
});

// Withdraw pending royalties
await ipulse.royalties.withdraw();
```

### MarketplaceClient

Trade and license IP assets.

```typescript
// Create listing
const listing = await ipulse.marketplace.createListing({
  ipAsset: ipAssetAddress,
  tokenId: tokenId,
  price: ethers.parseEther("0.5"),
  listingType: 'sale',
  duration: 30 * 24 * 60 * 60 // 30 days
});

// Buy IP asset
await ipulse.marketplace.buyIPAsset({
  listingId: listingId,
  value: price
});

// Purchase license
await ipulse.marketplace.purchaseLicense({
  listingId: listingId,
  licenseType: 'commercial',
  duration: 365 * 24 * 60 * 60,
  value: price
});

// Get user's listings
const myListings = await ipulse.marketplace.getUserListings(walletAddress);
```

### AnalyticsEngine

Get insights and valuations for IP assets.

```typescript
// Get IP analytics
const analytics = await ipulse.analytics.getAnalytics(ipAssetId);
console.log(analytics);
// {
//   totalRevenue: "2.5 ETH",
//   derivativeCount: 15,
//   licenseCount: 42,
//   estimatedValue: "5.2 ETH",
//   trendScore: 87
// }

// Get IP valuation
const valuation = await ipulse.analytics.getValuation(ipAssetId);
console.log(valuation);
// {
//   currentValue: "2.5 ETH",
//   projectedValue: "5.2 ETH",
//   confidence: 0.87,
//   factors: {
//     derivativeActivity: 0.92,
//     marketDemand: 0.78,
//     creatorReputation: 0.85,
//     contentQuality: 0.94
//   }
// }
```

## Advanced Usage

### Custom Configuration

```typescript
const ipulse = new IPulseClient({
  // Use custom signer instead of private key
  signer: customSigner,

  // Custom RPC URL
  rpcUrl: 'https://custom-rpc.example.com',

  // Custom contract addresses
  contractAddresses: {
    marketplace: '0x...',
    royaltyDistributor: '0x...',
    derivativeTracker: '0x...'
  },

  // AI configuration
  aiConfig: {
    openaiApiKey: process.env.OPENAI_API_KEY,
    stabilityApiKey: process.env.STABILITY_API_KEY,
    runwayApiKey: process.env.RUNWAY_API_KEY
  }
});
```

### Error Handling

```typescript
try {
  const ipAsset = await ipulse.ipAssets.register({
    name: 'My IP',
    contentUrl: 'ipfs://...',
    creator: walletAddress
  });
} catch (error) {
  if (error.code === 'INSUFFICIENT_FUNDS') {
    console.error('Not enough funds');
  } else if (error.code === 'ALREADY_EXISTS') {
    console.error('IP already registered');
  } else {
    console.error('Unknown error:', error);
  }
}
```

### Events

```typescript
// Listen for marketplace events
ipulse.marketplace.on('ListingCreated', (event) => {
  console.log('New listing:', event);
});

ipulse.marketplace.on('ListingSold', (event) => {
  console.log('IP sold:', event);
});

// Listen for royalty events
ipulse.royalties.on('RoyaltyDistributed', (event) => {
  console.log('Royalty distributed:', event);
});
```

## Examples

See the `/examples` directory for complete working examples:

- [Basic IP Registration](./examples/basic-registration.ts)
- [AI Content Generation](./examples/ai-generation.ts)
- [Marketplace Trading](./examples/marketplace.ts)
- [Derivative Works](./examples/derivatives.ts)
- [Royalty Distribution](./examples/royalties.ts)

## TypeScript Support

The SDK is written in TypeScript and includes full type definitions:

```typescript
import type {
  IPAsset,
  License,
  MarketplaceListing,
  DerivativeWork,
  IPAnalytics
} from '@ipulse/sdk';
```

## API Reference

Full API documentation available at: [https://docs.ipulse.studio/sdk](https://docs.ipulse.studio/sdk)

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## License

MIT License - see [LICENSE](../LICENSE) for details.

## Support

- **Documentation**: https://docs.ipulse.studio
- **GitHub Issues**: https://github.com/govardhan666/surreal_2/issues
- **Discord**: Join our community
- **Twitter**: @IPulseStudio

---

Built with ❤️ for the Surreal World Assets Buildathon
