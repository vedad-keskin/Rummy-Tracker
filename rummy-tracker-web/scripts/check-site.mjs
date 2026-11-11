import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';

const output = new URL('../dist/rummy-tracker-web/browser/', import.meta.url);
const home = readFileSync(new URL('index.html', output), 'utf8');
const privacy = readFileSync(new URL('privacy/index.html', output), 'utf8');

assert.match(home, /Deal the cards\./, 'Homepage must be prerendered');
assert.match(privacy, /<h1[^>]*>Privacy policy\./, 'Policy must be readable in the exported HTML');
for (const value of ['Rummy Tracker', 'Nightfall Studio', 'vedad.keskin98@gmail.com',
  'policy-en', 'policy-bs', 'lang="bs"', 'en-backups', '2026-11-11']) {
  assert.ok(privacy.includes(value), 'Missing privacy content: ' + value);
}
assert.match(privacy, /system backups/, 'Policy must disclose device-managed backups');
assert.doesNotMatch(privacy, /policy-contact|Have a question\?|Imate pitanje\?/, 'Removed contact section must not appear');
for (const html of [home, privacy]) {
  assert.doesNotMatch(html, /Vedad\s+Keskin/i, 'Website must credit Nightfall Studio');
  assert.match(html, /href="\/privacy"/, 'Privacy must be linked from both pages');
  assert.doesNotMatch(html, /href="\/?listing(?:\/|"|#)/, 'Removed listing page must not be linked');
  assert.doesNotMatch(html, /<script[^>]+src="https?:/i, 'No external tracking scripts');
}
assert.ok(!existsSync(new URL('listing/index.html', output)), 'Only the requested pages should be exported');
for (const name of ['logo.png', 'nightfall-wordmark.png', 'game-night-hero.webp', 'favicon.png', 'apple-touch-icon.png']) {
  assert.ok(readFileSync(new URL(name, output)).length > 0, 'Missing image: ' + name);
}
console.log('Site checks passed: two public pages, bilingual prerendered policy, contact, backups, links and images.');
