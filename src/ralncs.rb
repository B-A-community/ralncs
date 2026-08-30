# RALNCS — RAL / NCS palettes and material audit for SketchUp
# Loader: registers the extension.

require 'sketchup.rb'
require 'extensions.rb'

module RALNCS
  unless file_loaded?(__FILE__)
    ex = SketchupExtension.new('RALNCS', 'ralncs/main')
    ex.description = 'Палитры RAL Classic и NCS 1950: веер цветов, покраска и ' \
                     'автоматический подбор ближайших RAL/NCS для материалов модели (ТЗ).'
    ex.version     = '0.2.0'
    ex.creator     = 'Maksar & Ruslan'
    ex.copyright   = '2026'
    Sketchup.register_extension(ex, true)
    file_loaded(__FILE__)
  end
end
