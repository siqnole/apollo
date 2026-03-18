/**
 * Parse comma-separated environment variables into arrays
 * Supports single values or comma-separated lists
 * Examples:
 *   "http://localhost:3000" => ["http://localhost:3000"]
 *   "http://localhost:3000,http://example.com" => ["http://localhost:3000", "http://example.com"]
 */
export function parseUrlList(envValue: string | undefined, defaultUrl: string): string[] {
  if (!envValue) return [defaultUrl];
  return envValue.split(',').map(url => url.trim()).filter(Boolean);
}

/**
 * Get the primary URL from a list (first one)
 */
export function getPrimaryUrl(urls: string[]): string {
  return urls[0] || 'http://localhost:3000';
}
