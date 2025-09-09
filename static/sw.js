// Service Worker para BitácoraAPP PWA
const CACHE_NAME = 'bitacora-app-v1.0.0';
const STATIC_CACHE = 'bitacora-static-v1.0.0';
const DYNAMIC_CACHE = 'bitacora-dynamic-v1.0.0';

// Archivos estáticos para cache
const STATIC_FILES = [
  '/',
  '/static/css/styles.css',
  '/static/imagenes/logo.jpg',
  '/static/imagenes/logo2.ico',
  '/static/imagenes/logo2.jpg',
  '/static/manifest.json',
  'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css',
  'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css',
  'https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap'
];

// Instalación del Service Worker
self.addEventListener('install', event => {
  console.log('Service Worker: Instalando...');
  
  event.waitUntil(
    caches.open(STATIC_CACHE)
      .then(cache => {
        console.log('Service Worker: Cacheando archivos estáticos');
        return cache.addAll(STATIC_FILES);
      })
      .then(() => {
        console.log('Service Worker: Instalación completada');
        return self.skipWaiting();
      })
      .catch(error => {
        console.error('Service Worker: Error en instalación:', error);
      })
  );
});

// Activación del Service Worker
self.addEventListener('activate', event => {
  console.log('Service Worker: Activando...');
  
  event.waitUntil(
    caches.keys()
      .then(cacheNames => {
        return Promise.all(
          cacheNames.map(cacheName => {
            if (cacheName !== STATIC_CACHE && cacheName !== DYNAMIC_CACHE) {
              console.log('Service Worker: Eliminando cache antiguo:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      })
      .then(() => {
        console.log('Service Worker: Activación completada');
        return self.clients.claim();
      })
  );
});

// Interceptar requests
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);
  
  // Estrategia para archivos estáticos
  if (STATIC_FILES.includes(url.pathname) || url.pathname.startsWith('/static/')) {
    event.respondWith(
      caches.match(request)
        .then(response => {
          if (response) {
            return response;
          }
          return fetch(request)
            .then(fetchResponse => {
              const responseClone = fetchResponse.clone();
              caches.open(STATIC_CACHE)
                .then(cache => {
                  cache.put(request, responseClone);
                });
              return fetchResponse;
            });
        })
        .catch(() => {
          // Fallback para archivos estáticos
          if (request.destination === 'document') {
            return caches.match('/');
          }
        })
    );
  }
  
  // Estrategia para API y páginas dinámicas
  else if (url.pathname.startsWith('/formulario') || 
           url.pathname.startsWith('/admin') || 
           url.pathname.startsWith('/buscar') ||
           url.pathname.startsWith('/correos')) {
    
    event.respondWith(
      fetch(request)
        .then(response => {
          // Cachear respuestas exitosas
          if (response.status === 200) {
            const responseClone = response.clone();
            caches.open(DYNAMIC_CACHE)
              .then(cache => {
                cache.put(request, responseClone);
              });
          }
          return response;
        })
        .catch(() => {
          // Fallback offline
          return caches.match(request)
            .then(response => {
              if (response) {
                return response;
              }
              
              // Página offline personalizada
              if (request.destination === 'document') {
                return new Response(`
                  <!DOCTYPE html>
                  <html lang="es">
                  <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>BitácoraAPP - Sin conexión</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
                    <style>
                      body { 
                        background: linear-gradient(135deg, #2c2a63 0%, #1a1a3a 100%);
                        min-height: 100vh;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: white;
                        font-family: 'Segoe UI', sans-serif;
                      }
                      .offline-container {
                        text-align: center;
                        padding: 2rem;
                        background: rgba(255,255,255,0.1);
                        border-radius: 15px;
                        backdrop-filter: blur(10px);
                      }
                      .offline-icon {
                        font-size: 4rem;
                        margin-bottom: 1rem;
                        color: #ffc107;
                      }
                    </style>
                  </head>
                  <body>
                    <div class="offline-container">
                      <div class="offline-icon">📱</div>
                      <h2>Sin conexión a internet</h2>
                      <p>La aplicación está funcionando en modo offline.</p>
                      <p>Algunas funcionalidades pueden estar limitadas.</p>
                      <button class="btn btn-warning mt-3" onclick="window.location.reload()">
                        Reintentar conexión
                      </button>
                    </div>
                  </body>
                  </html>
                `, {
                  headers: { 'Content-Type': 'text/html' }
                });
              }
            });
        })
    );
  }
  
  // Para otros requests, usar estrategia network first
  else {
    event.respondWith(
      fetch(request)
        .catch(() => {
          return caches.match(request);
        })
    );
  }
});

// Manejar mensajes del cliente
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  
  if (event.data && event.data.type === 'GET_VERSION') {
    event.ports[0].postMessage({ version: CACHE_NAME });
  }
});

// Notificaciones push (para futuras implementaciones)
self.addEventListener('push', event => {
  if (event.data) {
    const data = event.data.json();
    const options = {
      body: data.body,
      icon: '/static/imagenes/logo2.ico',
      badge: '/static/imagenes/logo2.ico',
      vibrate: [100, 50, 100],
      data: {
        dateOfArrival: Date.now(),
        primaryKey: 1
      },
      actions: [
        {
          action: 'explore',
          title: 'Ver detalles',
          icon: '/static/imagenes/logo2.ico'
        },
        {
          action: 'close',
          title: 'Cerrar',
          icon: '/static/imagenes/logo2.ico'
        }
      ]
    };
    
    event.waitUntil(
      self.registration.showNotification(data.title, options)
    );
  }
});

// Manejar clics en notificaciones
self.addEventListener('notificationclick', event => {
  event.notification.close();
  
  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/admin')
    );
  } else if (event.action === 'close') {
    // Solo cerrar la notificación
  } else {
    // Clic en el cuerpo de la notificación
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});

console.log('Service Worker: Cargado correctamente');
