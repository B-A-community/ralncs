# Загрузка палитр RAL Classic / NCS 1950 и поиск ближайшего цвета.
# Lab считается один раз при первом обращении и кэшируется в памяти.

require 'json'
require_relative 'color_math'

module RALNCS
  module Palette
    DATA_DIR = File.join(__dir__, 'data')

    module_function

    def ral
      @ral ||= load_palette('ral_classic.json')
    end

    def ncs
      @ncs ||= load_palette('ncs_1950.json')
    end

    def load_palette(filename)
      path = File.join(DATA_DIR, filename)
      JSON.parse(File.read(path, encoding: 'UTF-8')).map do |item|
        r, g, b = ColorMath.hex_to_rgb(item['hex'])
        {
          code: item['code'],
          name: item['name'],
          hex: item['hex'],
          rgb: [r, g, b],
          lab: ColorMath.rgb_to_lab(r, g, b)
        }
      end
    end

    # Сколько кандидатов по дешёвому CIE76 берём в точный расчёт CIEDE2000.
    CANDIDATES = 40
    # Если и среди кандидатов ΔE велик, цвет далеко от палитры — там CIE76
    # и CIEDE2000 расходятся, поэтому такие цвета досчитываем полным перебором.
    # На реальной модели (763 уникальных цвета) это единицы, зато результат
    # везде совпадает с честным минимумом CIEDE2000.
    EXHAUSTIVE_ABOVE = 8.0

    # Ближайший цвет палитры к rgb-цвету. Возвращает {entry:, de:}.
    def nearest(palette, r, g, b)
      lab = ColorMath.rgb_to_lab(r, g, b)
      l0, a0, b0 = lab
      candidates = palette.min_by(CANDIDATES) do |e|
        l, a, bb = e[:lab]
        (l - l0)**2 + (a - a0)**2 + (bb - b0)**2
      end
      best = best_of(candidates, lab)
      best = best_of(palette, lab) if best[:de] > EXHAUSTIVE_ABOVE
      best
    end

    def best_of(entries, lab)
      best = nil
      best_de = Float::INFINITY
      entries.each do |entry|
        de = ColorMath.delta_e2000(lab, entry[:lab])
        if de < best_de
          best_de = de
          best = entry
        end
      end
      { entry: best, de: best_de }
    end

    def nearest_ral(r, g, b) = nearest(ral, r, g, b)
    def nearest_ncs(r, g, b) = nearest(ncs, r, g, b)
  end
end
