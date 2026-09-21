# RALNCS — RAL / NCS palettes and material audit for SketchUp
# Loader: registers the extension.

require 'sketchup.rb'
require 'extensions.rb'
require_relative 'ralncs/lang'

module RALNCS
  unless file_loaded?(__FILE__)
    ex = SketchupExtension.new('RALNCS', 'ralncs/main')
    ex.description = RALNCS.t(:ext_description)
    ex.version     = '1.0'
    ex.creator     = 'Maksar & Ruslan'
    ex.copyright   = '2026'
    Sketchup.register_extension(ex, true)
    file_loaded(__FILE__)
  end
end
