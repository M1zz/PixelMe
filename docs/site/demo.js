// 한땀 웹 데모: 사진 한 장을 Perler 비즈 도안으로 바꾼다. 사진은 이 브라우저 밖으로 나가지 않는다.
// 규칙은 앱의 PatternEngine 과 같다. 칸마다 4×4 로 평균색을 내고, CIE94 로 가장 가까운 Perler 색을 고른 뒤,
// 색 수 상한까지 가장 적게 쓴 색부터 지워 남은 색 중 가까운 색으로 옮긴다. 색표는 PatternColorData.perler 그대로.
(() => {
  const root = document.getElementById("demo");
  if (!root) return;
  const T = JSON.parse(root.dataset.text);
  const here = document.currentScript ? document.currentScript.src : location.href;
  const SAMPLE = new URL("screenshots/raw/assets/demo-beagle.jpg", here).href;
  const PERLER = "80-15179,Evergreen,305545;80-15181,Light Grey,b3bab8;80-15182,Lavender,af9fce;80-15199,Shamrock,008f53;80-15200,Cobalt,0065b1;80-15201,Midnight,2f3c55;80-15202,Robin's Egg,a9cdd5;80-15203,Flamingo,f2afb7;80-15204,Salmon,e1747a;80-15205,Fawn,c9a385;80-15206,Pewter,94a19d;80-15207,Charcoal,4f595a;80-15208,Toasted Marshmallow,dedace;80-15210,Orchid,b1628e;80-15211,Tomato,d14337;80-15212,Spice,d9593a;80-15213,Apricot,f5a168;80-15214,Sherbet,d8e47c;80-15215,Mist,93b0bd;80-15216,Sky,4ac0d8;80-15217,Lagoon,00a4ac;80-15218,Teal,047f8a;80-15219,Fern,7f971a;80-15220,Olive,696e31;80-15961,Cherry,9d2b3a;80-19001,White,eaefee;80-19002,Creme,e1e2bb;80-19003,Yellow,e7ce3e;80-19004,Orange,eb7b31;80-19005,Red,b0353c;80-19006,Bubblegum,d8729a;80-19007,Purple,684b86;80-19008,Dark Blue,0e5092;80-19009,Light Blue,278cc9;80-19010,Dark Green,007b4e;80-19011,Light Green,18c7b1;80-19012,Brown,674c44;80-19017,Grey,909497;80-19018,Black,323234;80-19020,Rust,995043;80-19021,Light Brown,936848;80-19033,Peach,e9bfb9;80-19035,Tan,c5ac90;80-19038,Magenta,e04284;80-19052,Pastel Blue,4a9ccf;80-19053,Pastel Green,6dcc94;80-19054,Pastel Lavender,937fbf;80-19056,Pastel Yellow,e9e290;80-19057,Cheddar,fbb146;80-19058,Toothpaste,96d1d4;80-19059,Hot Coral,dd595b;80-19060,Plum,a75d9d;80-19061,Kiwi Lime,69b845;80-19062,Turquoise,0098c5;80-19063,Blush,f99297;80-19070,Periwinkle Blue,6683b7;80-19079,Light Pink,e1bcce;80-19080,Green,4dab64;80-19083,Pink,d45496;80-19088,Raspberry,983864;80-19090,Butterscotch,da9964;80-19091,Parrot Green,009188;80-19092,Dark Grey,585c61;80-19093,Blueberry Creme,85a8e3;80-19096,Cranapple,843947;80-19097,Prickly Pear,bbc938;80-19098,Sand,e5be9e;80-15240,Mint,b3eed5;80-15241,Sour Apple,a3de6f;80-15242,Cotton Candy,f479b0;80-15243,Grape,503b9c;80-15244,Rose,d25d72;80-15245,Iris,4e56a3;80-15246,Tangerine,fd5918;80-15247,Forest,005d57;80-15248,Eggplant,6f3255;80-15249,Honey,da8c2c;80-15250,Gingerbread,7e5446;80-15251,Thistle,8c8ca7;80-15252,Slate Blue,5e6d7b;80-15253,Denim,4c6388;80-15254,Sage,9aa98e;80-15255,Orange Cream,efb79b;80-15256,Fruit Punch,ca3b65;80-15257,Fuchsia,cb59b9;80-15258,Mulberry,714875;80-15259,Slime,c8c85c;80-15260,Stone,988c8c;80-15261,Dark Spruce,14313b;80-15262,Cocoa,392928;80-15265,Twilight Plum,c685b1;80-15266,Caribbean Sea,6cc8ad;80-15267,Frosted Lilac,cdb7c3;80-15273,Brick,fc9574;80-15274,Rich Butter,f6ca69;80-15275,Peacock,0090ac;80-15276,Carnation Pink,f8c7c9;80-15089,Neon Blue,406ae1;80-15268,Sunflower,deba0b;80-15269,Lemon,f6d901;80-15263,Celery,bed4a6;80-15239,Mocha,c8b693;80-15272,Coral,ff9a8b".split(";").map(s => { const [code, name, hex] = s.split(","); const n = parseInt(hex, 16);
    return { code, name, r: n >> 16, g: n >> 8 & 255, b: n & 255 }; });

  // sRGB → CIELAB, CIE94 (PatternEngine.Lab · deltaE94)
  const lin = v => (v /= 255) <= 0.04045 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4;
  const f = t => t > 0.008856 ? Math.cbrt(t) : 7.787 * t + 16 / 116;
  function lab(r, g, b) {
    const R = lin(r), G = lin(g), B = lin(b);
    const x = f((0.4124 * R + 0.3576 * G + 0.1805 * B) / 0.95047), y = f(0.2126 * R + 0.7152 * G + 0.0722 * B),
          z = f((0.0193 * R + 0.1192 * G + 0.9505 * B) / 1.08883);
    return [116 * y - 16, 500 * (x - y), 200 * (y - z)];
  }
  function dE94(p, q) {
    const c1 = Math.hypot(p[1], p[2]), c2 = Math.hypot(q[1], q[2]), dC = c1 - c2, dL = p[0] - q[0];
    const dH2 = Math.max(0, (p[1] - q[1]) ** 2 + (p[2] - q[2]) ** 2 - dC * dC);
    const sC = 1 + 0.045 * c1, sH = 1 + 0.015 * c1;
    return Math.sqrt(dL * dL + (dC / sC) ** 2 + dH2 / (sH * sH));
  }
  const PAL = PERLER.map(c => lab(c.r, c.g, c.b));
  function nearest(l, allowed) {
    let best = 0, bd = Infinity;
    PAL.forEach((p, i) => { if (allowed && !allowed.has(i)) return; const d = dE94(l, p); if (d < bd) { bd = d; best = i; } });
    return best;
  }

  function makePattern(img, side, maxColors) {
    const w = img.width >= img.height ? side : Math.max(1, Math.round(side * img.width / img.height));
    const h = img.width >= img.height ? Math.max(1, Math.round(side * img.height / img.width)) : side;
    const o = 4, c = document.createElement("canvas");
    c.width = w * o; c.height = h * o;
    const g = c.getContext("2d", { willReadFrequently: true });
    g.imageSmoothingQuality = "high";
    g.drawImage(img, 0, 0, c.width, c.height);
    const px = g.getImageData(0, 0, c.width, c.height).data;
    const cellLab = [], assigned = new Array(w * h).fill(-1), cache = new Map();
    for (let cy = 0; cy < h; cy++) for (let cx = 0; cx < w; cx++) {
      let r = 0, gg = 0, b = 0, a = 0;
      for (let sy = 0; sy < o; sy++) for (let sx = 0; sx < o; sx++) {
        const k = ((cy * o + sy) * c.width + cx * o + sx) * 4, al = px[k + 3];
        r += px[k] * al; gg += px[k + 1] * al; b += px[k + 2] * al; a += al;
      }
      const i = cy * w + cx;
      if (a / (o * o) < 128) continue;                       // 투명한 칸은 빈칸
      const rgb = [r / a, gg / a, b / a].map(Math.round), key = rgb.join();
      cellLab[i] = lab(...rgb);
      if (!cache.has(key)) cache.set(key, nearest(cellLab[i]));
      assigned[i] = cache.get(key);
    }
    const counts = new Array(PAL.length).fill(0);
    assigned.forEach(x => x >= 0 && counts[x]++);
    const allowed = new Set(counts.map((n, i) => n > 0 ? i : -1).filter(i => i >= 0));
    while (allowed.size > Math.max(2, maxColors)) {
      const victim = [...allowed].reduce((m, i) => counts[i] < counts[m] ? i : m);
      allowed.delete(victim);
      assigned.forEach((x, i) => { if (x === victim) { const n = nearest(cellLab[i], allowed); assigned[i] = n; counts[n]++; } });
      counts[victim] = 0;
    }
    return { w, h, cells: assigned, counts };
  }

  root.innerHTML = `
    <div class="bead-stage">
      <div class="bead-pic"><canvas class="bead-out" role="img" aria-label="${T.alt}"></canvas>
        <img class="bead-src" alt="${T.photo}"></div>
      <p class="bead-info muted small" aria-live="polite"></p>
    </div>
    <div class="bead-controls">
      <p class="bead-label">${T.size}</p>
      <div class="bead-sizes" role="group" aria-label="${T.size}">
        ${[29, 58].map((s, i) => `<button type="button" class="chip" data-side="${s}" aria-pressed="${!i}">${s}<small>${T.boards[i]}</small></button>`).join("")}
      </div>
      <label class="bead-label bead-colors"><span></span>
        <input type="range" min="2" max="30" step="1" value="12"></label>
      <p class="bead-label">${T.need}</p>
      <ul class="bead-list"></ul>
      <label class="bead-file"><input type="file" accept="image/*">${T.mine}</label>
      <p class="muted small">${T.note}</p>
    </div>`;

  const $ = s => root.querySelector(s);
  const out = $(".bead-out"), src = $(".bead-src"), range = $('input[type="range"]');
  let side = 29, img = new Image(), timer;
  const num = n => n.toLocaleString(document.documentElement.lang);
  const fill = (s, v) => s.replace(/\{(\w+)\}/g, (_, k) => v[k]);

  function render() {
    if (!img.naturalWidth) return;
    const p = makePattern(img, side, +range.value), cell = 10;
    out.width = p.w * cell; out.height = p.h * cell;
    const g = out.getContext("2d");
    g.clearRect(0, 0, out.width, out.height);
    p.cells.forEach((ci, i) => {
      const x = (i % p.w) * cell + cell / 2, y = Math.floor(i / p.w) * cell + cell / 2, c = PERLER[ci];
      g.beginPath();
      if (ci < 0) { g.fillStyle = "#e6e6e6"; g.arc(x, y, cell * 0.12, 0, 7); g.fill(); return; }
      g.fillStyle = `rgb(${c.r},${c.g},${c.b})`; g.arc(x, y, cell * 0.48, 0, 7); g.fill();
      g.beginPath(); g.fillStyle = "rgba(255,255,255,.6)"; g.arc(x, y, cell * 0.12, 0, 7); g.fill();
    });
    g.strokeStyle = "rgba(0,0,0,.45)"; g.lineWidth = 2;                 // 보드 경계(29칸)
    for (let b = 29; b < Math.max(p.w, p.h); b += 29) {
      g.beginPath(); g.moveTo(b * cell, 0); g.lineTo(b * cell, out.height); g.moveTo(0, b * cell); g.lineTo(out.width, b * cell); g.stroke();
    }
    const used = p.counts.map((n, i) => ({ n, c: PERLER[i] })).filter(u => u.n > 0).sort((a, b) => b.n - a.n);
    const beads = used.reduce((s, u) => s + u.n, 0);
    $(".bead-info").textContent = fill(T.info, { w: p.w, h: p.h, cw: num(p.w / 2), ch: num(p.h / 2), n: num(beads), c: used.length });
    $(".bead-list").innerHTML = used.slice(0, 8).map(u =>
      `<li><i style="background:rgb(${u.c.r},${u.c.g},${u.c.b})"></i><span>${u.c.code} ${u.c.name}</span><b>${num(u.n)}</b></li>`).join("")
      + (used.length > 8 ? `<li class="muted">${fill(T.more, { n: used.length - 8 })}</li>` : "");
  }
  function update() {
    $(".bead-colors span").textContent = fill(T.colors, { n: range.value });
    range.setAttribute("aria-valuetext", fill(T.colors, { n: range.value }));
    clearTimeout(timer); timer = setTimeout(render, 30);
  }
  function load(url) { img = new Image(); img.onload = () => { src.src = url; update(); }; img.src = url; }

  root.addEventListener("click", e => {
    const b = e.target.closest("[data-side]");
    if (!b) return;
    side = +b.dataset.side;
    root.querySelectorAll("[data-side]").forEach(x => x.setAttribute("aria-pressed", String(x === b)));
    update();
  });
  range.addEventListener("input", update);
  $('input[type="file"]').addEventListener("change", e => { const file = e.target.files[0]; if (file) load(URL.createObjectURL(file)); });
  load(SAMPLE);
})();
