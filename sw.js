/* First Word — service worker (v0.4)
   Subpath-safe: every path is relative to this file's directory (/verse-alarm/).
   Strategy: network-first for the page (updates always land; offline falls back to cache),
   cache-first for static assets (icons, manifest). Versioned cache, old caches purged. */
const CACHE = "firstword-v0.4.0";
const ASSETS = [
  "./",
  "./index.html",
  "./manifest.json",
  "./icons/icon-32.png",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/apple-touch-icon.png",
  "./icons/maskable-512.png"
];

self.addEventListener("install", e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET" || !req.url.startsWith(self.location.origin)) return;

  // The page itself: always try the network first so a new deploy is picked up
  // on the next load; fall back to the cached copy when offline.
  if (req.mode === "navigate") {
    e.respondWith(
      fetch(req)
        .then(r => {
          const copy = r.clone();
          caches.open(CACHE).then(c => c.put("./index.html", copy));
          return r;
        })
        .catch(() => caches.match("./index.html"))
    );
    return;
  }

  // Static assets: cache-first, backfill from network.
  e.respondWith(
    caches.match(req).then(hit =>
      hit ||
      fetch(req).then(r => {
        const copy = r.clone();
        caches.open(CACHE).then(c => c.put(req, copy));
        return r;
      })
    )
  );
});
