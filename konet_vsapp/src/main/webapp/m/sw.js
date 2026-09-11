/* 코네트 모바일 PWA 서비스워커 (scope = 이 파일이 있는 /m/ 폴더)
 * - 화면 뼈대(아이콘·manifest)만 미리 담아 둔다.
 * - *.do (업무 자료·화면) 는 **절대 캐시하지 않는다** — 금액·재고는 늘 서버 값이어야 한다.
 *   네트워크가 끊기면 화면 요청에만 «연결 없음» 안내를 돌려준다.
 * - 경로는 모두 이 파일 기준 상대경로 — 컨텍스트 경로가 붙어 배포돼도 그대로 동작한다.
 * - 파일을 고치면 VER 를 올린다(옛 캐시를 지운다).
 */
var VER = 'konet-m-20260911b';   // b : 판매·수금지급·재고 화면 + manifest 바로가기
var SHELL = ['manifest.json', 'icons/icon-192.png', 'icons/icon-512.png'];

self.addEventListener('install', function (e) {
  e.waitUntil(caches.open(VER).then(function (c) { return c.addAll(SHELL); }));
  self.skipWaiting();
});

self.addEventListener('activate', function (e) {
  e.waitUntil(caches.keys().then(function (ks) {
    return Promise.all(ks.filter(function (k) { return k !== VER; }).map(function (k) { return caches.delete(k); }));
  }));
  self.clients.claim();
});

var OFFLINE_HTML =
  '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">' +
  '<body style="font-family:sans-serif;padding:40px 20px;text-align:center;color:#334;background:#f4f7f6">' +
  '<h2 style="color:#137a6c">연결 없음</h2><p>인터넷 연결을 확인한 뒤 다시 열어 주세요.</p>' +
  '<button onclick="location.reload()" style="padding:10px 22px;border:0;border-radius:8px;background:#137a6c;color:#fff;font-size:15px">다시 시도</button></body>';

self.addEventListener('fetch', function (e) {
  var req = e.request;
  if (req.method !== 'GET') return;
  var url = new URL(req.url);
  if (url.origin !== location.origin) return;

  // 업무 자료·화면(*.do) = 네트워크만. 끊겼을 때 화면 요청이면 안내 페이지.
  if (/\.do$/.test(url.pathname)) {
    if (req.mode === 'navigate') {
      e.respondWith(fetch(req).catch(function () {
        return new Response(OFFLINE_HTML, { headers: { 'Content-Type': 'text/html; charset=utf-8' } });
      }));
    }
    return;
  }

  // 뼈대 파일(scope 안) = 캐시 우선
  if (req.url.indexOf(self.registration.scope) === 0) {
    e.respondWith(caches.match(req).then(function (hit) { return hit || fetch(req); }));
  }
});
