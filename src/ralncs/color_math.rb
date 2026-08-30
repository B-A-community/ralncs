# Цветовая математика: sRGB -> CIELAB (D65) и Delta E (CIEDE2000).
# Подбор по простому RGB-расстоянию даёт визуально плохие пары,
# поэтому всё сравнение цветов идёт только через Lab + CIEDE2000.

module RALNCS
  module ColorMath
    module_function

    # "#CDBA88" -> [205, 186, 136]
    def hex_to_rgb(hex)
      h = hex.delete('#')
      [h[0, 2], h[2, 2], h[4, 2]].map { |c| c.to_i(16) }
    end

    def rgb_to_hex(r, g, b)
      format('#%02X%02X%02X', r, g, b)
    end

    # sRGB (0..255) -> CIELAB, эталонный источник D65
    def rgb_to_lab(r, g, b)
      rl, gl, bl = [r, g, b].map do |c|
        c = c / 255.0
        c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4
      end

      x = 0.4124564 * rl + 0.3575761 * gl + 0.1804375 * bl
      y = 0.2126729 * rl + 0.7151522 * gl + 0.0721750 * bl
      z = 0.0193339 * rl + 0.1191920 * gl + 0.9503041 * bl

      fx = lab_f(x / 0.95047)
      fy = lab_f(y / 1.0)
      fz = lab_f(z / 1.08883)

      [116.0 * fy - 16.0, 500.0 * (fx - fy), 200.0 * (fy - fz)]
    end

    def lab_f(t)
      t > 0.008856 ? t**(1.0 / 3.0) : 7.787 * t + 16.0 / 116.0
    end

    # CIEDE2000. Вход — два массива [L, a, b].
    def delta_e2000(lab1, lab2)
      l1, a1, b1 = lab1
      l2, a2, b2 = lab2

      c1 = Math.sqrt(a1 * a1 + b1 * b1)
      c2 = Math.sqrt(a2 * a2 + b2 * b2)
      c_bar = (c1 + c2) / 2.0

      g = 0.5 * (1.0 - Math.sqrt(c_bar**7 / (c_bar**7 + 25.0**7)))
      a1p = (1.0 + g) * a1
      a2p = (1.0 + g) * a2
      c1p = Math.sqrt(a1p * a1p + b1 * b1)
      c2p = Math.sqrt(a2p * a2p + b2 * b2)

      h1p = hue_deg(b1, a1p)
      h2p = hue_deg(b2, a2p)

      dlp = l2 - l1
      dcp = c2p - c1p

      dhp =
        if c1p * c2p == 0.0
          0.0
        elsif (h2p - h1p).abs <= 180.0
          h2p - h1p
        elsif h2p - h1p > 180.0
          h2p - h1p - 360.0
        else
          h2p - h1p + 360.0
        end
      dbig_hp = 2.0 * Math.sqrt(c1p * c2p) * Math.sin(deg2rad(dhp) / 2.0)

      l_bar = (l1 + l2) / 2.0
      cp_bar = (c1p + c2p) / 2.0
      h_bar =
        if c1p * c2p == 0.0
          h1p + h2p
        elsif (h1p - h2p).abs <= 180.0
          (h1p + h2p) / 2.0
        elsif h1p + h2p < 360.0
          (h1p + h2p + 360.0) / 2.0
        else
          (h1p + h2p - 360.0) / 2.0
        end

      t = 1.0 -
          0.17 * Math.cos(deg2rad(h_bar - 30.0)) +
          0.24 * Math.cos(deg2rad(2.0 * h_bar)) +
          0.32 * Math.cos(deg2rad(3.0 * h_bar + 6.0)) -
          0.20 * Math.cos(deg2rad(4.0 * h_bar - 63.0))

      d_theta = 30.0 * Math.exp(-(((h_bar - 275.0) / 25.0)**2))
      r_c = 2.0 * Math.sqrt(cp_bar**7 / (cp_bar**7 + 25.0**7))
      s_l = 1.0 + 0.015 * (l_bar - 50.0)**2 / Math.sqrt(20.0 + (l_bar - 50.0)**2)
      s_c = 1.0 + 0.045 * cp_bar
      s_h = 1.0 + 0.015 * cp_bar * t
      r_t = -Math.sin(deg2rad(2.0 * d_theta)) * r_c

      Math.sqrt(
        (dlp / s_l)**2 +
        (dcp / s_c)**2 +
        (dbig_hp / s_h)**2 +
        r_t * (dcp / s_c) * (dbig_hp / s_h)
      )
    end

    def hue_deg(b, ap)
      return 0.0 if b == 0.0 && ap == 0.0
      deg = rad2deg(Math.atan2(b, ap))
      deg < 0.0 ? deg + 360.0 : deg
    end

    def deg2rad(d) = d * Math::PI / 180.0
    def rad2deg(r) = r * 180.0 / Math::PI
  end
end
