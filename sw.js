// MediCore service worker: lets the app install on phones and open without network.
// Same-origin GET requests are network-first with a cached fallback. The cloud API
// (supabase.co) is never cached, so the data is always read and written live.
const CACHE = 'medicore-v2';
const SHELL = ['./', './index.html', './manifest.json', './assets/supabase.js',
               './assets/icon-192.png', './assets/icon-512.png'];

self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  const req = event.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  const sameSite = url.origin === self.location.origin;
  const sqlJs = url.hostname === 'cdnjs.cloudflare.com';
  if (!sameSite && !sqlJs) return;   // cloud API and other hosts: straight to the network
  event.respondWith(
    fetch(req)
      .then(res => {
        if (res && (res.ok || res.type === 'opaque')) {
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(req, copy)).catch(() => {});
        }
        return res;
      })
      .catch(() => caches.match(req).then(r => r || (req.mode === 'navigate' ? caches.match('./index.html') : undefined)))
  );
});
