// Тестовый подбор ближайших RAL/NCS на JS — та же математика, что в color_math.rb.
(function () {
  function hexToRgb(hex) {
    var h = hex.replace('#', '');
    return [parseInt(h.substr(0, 2), 16), parseInt(h.substr(2, 2), 16), parseInt(h.substr(4, 2), 16)];
  }
  function labF(t) { return t > 0.008856 ? Math.pow(t, 1 / 3) : 7.787 * t + 16 / 116; }
  function rgbToLab(r, g, b) {
    var lin = [r, g, b].map(function (c) {
      c /= 255;
      return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
    });
    var x = 0.4124564 * lin[0] + 0.3575761 * lin[1] + 0.1804375 * lin[2];
    var y = 0.2126729 * lin[0] + 0.7151522 * lin[1] + 0.0721750 * lin[2];
    var z = 0.0193339 * lin[0] + 0.1191920 * lin[1] + 0.9503041 * lin[2];
    var fx = labF(x / 0.95047), fy = labF(y / 1.0), fz = labF(z / 1.08883);
    return [116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz)];
  }
  function deg2rad(d) { return d * Math.PI / 180; }
  function rad2deg(r) { return r * 180 / Math.PI; }
  function hueDeg(b, ap) { if (b === 0 && ap === 0) return 0; var d = rad2deg(Math.atan2(b, ap)); return d < 0 ? d + 360 : d; }
  function dE2000(lab1, lab2) {
    var l1 = lab1[0], a1 = lab1[1], b1 = lab1[2], l2 = lab2[0], a2 = lab2[1], b2 = lab2[2];
    var c1 = Math.sqrt(a1 * a1 + b1 * b1), c2 = Math.sqrt(a2 * a2 + b2 * b2), cBar = (c1 + c2) / 2;
    var g = 0.5 * (1 - Math.sqrt(Math.pow(cBar, 7) / (Math.pow(cBar, 7) + Math.pow(25, 7))));
    var a1p = (1 + g) * a1, a2p = (1 + g) * a2;
    var c1p = Math.sqrt(a1p * a1p + b1 * b1), c2p = Math.sqrt(a2p * a2p + b2 * b2);
    var h1p = hueDeg(b1, a1p), h2p = hueDeg(b2, a2p);
    var dlp = l2 - l1, dcp = c2p - c1p, dhp;
    if (c1p * c2p === 0) dhp = 0;
    else if (Math.abs(h2p - h1p) <= 180) dhp = h2p - h1p;
    else if (h2p - h1p > 180) dhp = h2p - h1p - 360;
    else dhp = h2p - h1p + 360;
    var dHp = 2 * Math.sqrt(c1p * c2p) * Math.sin(deg2rad(dhp) / 2);
    var lBar = (l1 + l2) / 2, cpBar = (c1p + c2p) / 2, hBar;
    if (c1p * c2p === 0) hBar = h1p + h2p;
    else if (Math.abs(h1p - h2p) <= 180) hBar = (h1p + h2p) / 2;
    else if (h1p + h2p < 360) hBar = (h1p + h2p + 360) / 2;
    else hBar = (h1p + h2p - 360) / 2;
    var t = 1 - 0.17 * Math.cos(deg2rad(hBar - 30)) + 0.24 * Math.cos(deg2rad(2 * hBar))
          + 0.32 * Math.cos(deg2rad(3 * hBar + 6)) - 0.20 * Math.cos(deg2rad(4 * hBar - 63));
    var dTheta = 30 * Math.exp(-Math.pow((hBar - 275) / 25, 2));
    var rC = 2 * Math.sqrt(Math.pow(cpBar, 7) / (Math.pow(cpBar, 7) + Math.pow(25, 7)));
    var sL = 1 + 0.015 * Math.pow(lBar - 50, 2) / Math.sqrt(20 + Math.pow(lBar - 50, 2));
    var sC = 1 + 0.045 * cpBar, sH = 1 + 0.015 * cpBar * t;
    var rT = -Math.sin(deg2rad(2 * dTheta)) * rC;
    return Math.sqrt(Math.pow(dlp / sL, 2) + Math.pow(dcp / sC, 2) + Math.pow(dHp / sH, 2)
                   + rT * (dcp / sC) * (dHp / sH));
  }

  var withLab = function (list) {
    return list.map(function (c) {
      var rgb = hexToRgb(c.hex);
      return { code: c.code, name: c.name, hex: c.hex, lab: rgbToLab(rgb[0], rgb[1], rgb[2]) };
    });
  };
  var RAL = withLab(FAN_DATA.ral);
  var NCS = withLab(FAN_DATA.ncs);

  function nearest(list, lab) {
    var best = null, bestDe = Infinity;
    list.forEach(function (c) {
      var de = dE2000(lab, c.lab);
      if (de < bestDe) { bestDe = de; best = c; }
    });
    return { code: best.code, name: best.name || null, hex: best.hex, de: Math.round(bestDe * 10) / 10 };
  }

  var samples = [
    ['Фасад основной', '#D8CBB5', false],
    ['Акцент красный', '#C1121F', false],
    ['Цоколь тёмный', '#4A4A44', false],
    ['Рамы окон', '#FFFFFF', false],
    ['Кровля', '#8D2E24', false],
    ['Зелёный от души', '#3FA34D', false],
    ['Кислотный (вне палитр)', '#00FF88', false],
    ['Кирпич лицевой (текстура)', '#C99A8E', true],
    ['Доска фасадная (текстура)', '#8A6B4F', true]
  ];
  var rows = samples.map(function (s) {
    var rgb = hexToRgb(s[1]);
    var lab = rgbToLab(rgb[0], rgb[1], rgb[2]);
    return { name: s[0], display_name: s[0], hex: s[1], textured: s[2],
             ral: nearest(RAL, lab), ncs: nearest(NCS, lab) };
  });
  window.TEST_ROWS = rows;
  var texCount = rows.filter(function (r) { return r.textured; }).length;
  init({ rows: rows, solid: rows.length - texCount, textured: texCount });
})();
