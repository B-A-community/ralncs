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

    # Ближайший цвет палитры к rgb-цвету. Возвращает {entry:, de:}.
    def nearest(palette, r, g, b)
      lab = ColorMath.rgb_to_lab(r, g, b)
      best = nil
      best_de = Float::INFINITY
      palette.each do |entry|
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
