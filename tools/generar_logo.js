// Genera un logo placeholder 512x512 para Kirolive (PNG, sin dependencias).
// Fondo: degradado naranja en un cuadrado redondeado. Encima: una "K" blanca.
const zlib = require('zlib');
const fs = require('fs');

const SIZE = 512;
const buf = Buffer.alloc(SIZE * SIZE * 4); // RGBA

function setPx(x, y, r, g, b, a) {
  const i = (y * SIZE + x) * 4;
  buf[i] = r; buf[i + 1] = g; buf[i + 2] = b; buf[i + 3] = a;
}

// distancia de un punto a un segmento (para dibujar trazos gruesos)
function distSeg(px, py, ax, ay, bx, by) {
  const dx = bx - ax, dy = by - ay;
  const len2 = dx * dx + dy * dy;
  let t = len2 === 0 ? 0 : ((px - ax) * dx + (py - ay) * dy) / len2;
  t = Math.max(0, Math.min(1, t));
  const cx = ax + t * dx, cy = ay + t * dy;
  return Math.hypot(px - cx, py - cy);
}

const radius = 96;       // esquinas redondeadas del fondo
const stroke = 46;       // grosor de la "K"
const half = stroke / 2;

// Geometría de la "K"
const vx = 168;                 // posición de la barra vertical
const topY = 150, botY = 362;   // alto de la K
const junctionX = vx, junctionY = (topY + botY) / 2;
const armX = 348;

for (let y = 0; y < SIZE; y++) {
  for (let x = 0; x < SIZE; x++) {
    // ¿dentro del cuadrado redondeado?
    let inside = true;
    const cx = Math.min(Math.max(x, radius), SIZE - radius);
    const cy = Math.min(Math.max(y, radius), SIZE - radius);
    if (Math.hypot(x - cx, y - cy) > radius) inside = false;

    if (!inside) { setPx(x, y, 0, 0, 0, 0); continue; }

    // degradado naranja diagonal (de #FF8A00 a #FC4C02)
    const t = (x + y) / (2 * SIZE);
    const r = Math.round(255 - t * (255 - 252));
    const g = Math.round(138 - t * (138 - 76));
    const b = Math.round(0 + t * 2);

    // ¿pertenece a la "K"?
    const dVert = (x >= vx - half && x <= vx + half && y >= topY - half && y <= botY + half)
      ? 0 : Infinity;
    const dUp = distSeg(x, y, junctionX, junctionY, armX, topY);
    const dDown = distSeg(x, y, junctionX, junctionY, armX, botY);
    const isK = dVert === 0 || dUp <= half || dDown <= half;

    if (isK) setPx(x, y, 255, 255, 255, 255);
    else setPx(x, y, r, g, b, 255);
  }
}

// --- Codificar como PNG (color type 6 = RGBA) ---
function crc32(data) {
  let c, table = crc32.t || (crc32.t = (() => {
    const t = [];
    for (let n = 0; n < 256; n++) {
      c = n;
      for (let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
      t[n] = c >>> 0;
    }
    return t;
  })());
  let crc = 0xFFFFFFFF;
  for (let i = 0; i < data.length; i++) crc = table[(crc ^ data[i]) & 0xFF] ^ (crc >>> 8);
  return (crc ^ 0xFFFFFFFF) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length, 0);
  const typeBuf = Buffer.from(type, 'ascii');
  const body = Buffer.concat([typeBuf, data]);
  const crc = Buffer.alloc(4); crc.writeUInt32BE(crc32(body), 0);
  return Buffer.concat([len, body, crc]);
}

// scanlines con byte de filtro 0 al inicio de cada fila
const raw = Buffer.alloc(SIZE * (SIZE * 4 + 1));
for (let y = 0; y < SIZE; y++) {
  raw[y * (SIZE * 4 + 1)] = 0;
  buf.copy(raw, y * (SIZE * 4 + 1) + 1, y * SIZE * 4, (y + 1) * SIZE * 4);
}
const idat = zlib.deflateSync(raw);

const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(SIZE, 0);
ihdr.writeUInt32BE(SIZE, 4);
ihdr[8] = 8;   // bit depth
ihdr[9] = 6;   // color type RGBA
ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;

const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
const png = Buffer.concat([
  sig,
  chunk('IHDR', ihdr),
  chunk('IDAT', idat),
  chunk('IEND', Buffer.alloc(0)),
]);

fs.writeFileSync('tools/kirolive_logo.png', png);
console.log('Logo generado: tools/kirolive_logo.png (' + png.length + ' bytes)');
