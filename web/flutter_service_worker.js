/* Eskolia: minimal service worker (network-only).
 * On activate: clears all Cache Storage (old Flutter precache).
 * fetch: always network — new deploys are picked up without user steps.
 * No offline PWA cache (acceptable for this training app).
 */
self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      try {
        const keys = await caches.keys();
        await Promise.all(keys.map((name) => caches.delete(name)));
      } catch (_) {}
      try {
        await self.clients.claim();
      } catch (_) {}
    })(),
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(fetch(event.request));
});
