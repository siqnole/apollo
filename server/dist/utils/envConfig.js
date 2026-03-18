"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseUrlList = parseUrlList;
exports.getPrimaryUrl = getPrimaryUrl;
/**
 * Parse comma-separated environment variables into arrays
 * Supports single values or comma-separated lists
 * Examples:
 *   "http://localhost:3000" => ["http://localhost:3000"]
 *   "http://localhost:3000,http://example.com" => ["http://localhost:3000", "http://example.com"]
 */
function parseUrlList(envValue, defaultUrl) {
    if (!envValue)
        return [defaultUrl];
    return envValue.split(',').map(url => url.trim()).filter(Boolean);
}
/**
 * Get the primary URL from a list (first one)
 */
function getPrimaryUrl(urls) {
    return urls[0] || 'http://localhost:3000';
}
