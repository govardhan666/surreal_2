/**
 * Utility functions for IPulse SDK
 */

/**
 * Format IPFS URL
 */
export function formatIPFSUrl(hash: string): string {
  if (hash.startsWith('ipfs://')) {
    return hash;
  }
  return `ipfs://${hash}`;
}

/**
 * Parse IPFS hash from URL
 */
export function parseIPFSHash(url: string): string {
  return url.replace('ipfs://', '');
}

/**
 * Convert basis points to percentage
 */
export function basisPointsToPercentage(basisPoints: number): number {
  return basisPoints / 100;
}

/**
 * Convert percentage to basis points
 */
export function percentageToBasisPoints(percentage: number): number {
  return Math.round(percentage * 100);
}
