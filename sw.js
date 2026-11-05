// MediCore service worker: lets the app install on phones and open with no network.
// The app shell (including the SQLite engine) is cached on the first visit, so the
// doctor can work offline afterwards. Same-origin GET requests are network-first with a
// cached fallback. Cloud API calls and fonts are never cached.
const CACHE = 'medicore-v3';
const SHELL = ['./', './index.html', './manifest.json', './assets/supabase.js',
               './assets/sql-wasm.js', './assets/sql-wasm.wasm',
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
  if (url.origin !== self.location.origin) return;   // cloud API and fonts: straight to the network
  event.respondWith(
    fetch(req)
      .then(res => {
        if (res && res.ok) {
          const copy = res.clone();
          caches.open(CACHE).then(c => c.put(req, copy)).catch(() => {});
        }
        return res;
      })
      .catch(() => caches.match(req).then(r => r || (req.mode === 'navigate' ? caches.match('./index.html') : undefined)))
  );
});
