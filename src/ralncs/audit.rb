# Анализ материалов модели: для каждого материала подбирает ближайшие
# RAL и NCS, показывает таблицу-ТЗ, умеет копировать её в буфер (для вставки
# в Google Таблицы) и перекрашивать однотонные материалы в точные цвета.
# У текстурных материалов цветом считается усреднённый цвет текстуры
# (его отдаёт сам SketchUp через Material#color); перекраска текстурных
# запрещена — она затонировала бы текстуру.

require 'json'
require_relative 'palette'
require_relative 'color_math'

module RALNCS
  module Audit
    module_function

    def show
      model = Sketchup.active_model
      if model.materials.count.zero?
        UI.messagebox('В модели нет материалов.')
        return
      end

      @dialog&.close
      @dialog = UI::HtmlDialog.new(
        dialog_title: 'RALNCS — анализ материалов (ТЗ)',
        preferences_key: 'ralncs_audit',
        width: 980,
        height: 640,
        style: UI::HtmlDialog::STYLE_DIALOG
      )
      @dialog.set_file(File.join(__dir__, 'html', 'audit.html'))

      @dialog.add_action_callback('ready')  { push_data }
      @dialog.add_action_callback('rescan') { push_data }
      @dialog.add_action_callback('apply') do |_ctx, json|
        apply(JSON.parse(json))
        push_data
      end

      @dialog.show
    end

    # Собирает все материалы модели и подбирает ближайшие RAL/NCS.
    def scan
      model = Sketchup.active_model
      rows = []
      model.materials.each do |m|
        c = m.color
        next unless c

        ral = Palette.nearest_ral(c.red, c.green, c.blue)
        ncs = Palette.nearest_ncs(c.red, c.green, c.blue)
        rows << {
          name: m.name,
          display_name: m.display_name,
          hex: ColorMath.rgb_to_hex(c.red, c.green, c.blue),
          textured: !m.texture.nil?,
          ral: match_payload(ral),
          ncs: match_payload(ncs)
        }
      end
      textured = rows.count { |r| r[:textured] }
      {
        rows: rows.sort_by { |r| r[:display_name].downcase },
        solid: rows.size - textured,
        textured: textured
      }
    end

    def match_payload(match)
      e = match[:entry]
      { code: e[:code], name: e[:name], hex: e[:hex], de: match[:de].round(1) }
    end

    def push_data
      @dialog.execute_script("init(#{scan.to_json})")
    end

    # params: {"palette"=>"ral"|"ncs", "names"=>[...]}
    # Красит только однотонные: перекраска текстурного тонирует текстуру.
    def apply(params)
      model = Sketchup.active_model
      palette_key = params['palette'] == 'ncs' ? :ncs : :ral

      model.start_operation("RALNCS: применить #{palette_key.to_s.upcase}", true)
      params['names'].each do |name|
        m = model.materials[name]
        next unless m && m.texture.nil?

        c = m.color
        match = palette_key == :ncs ? Palette.nearest_ncs(c.red, c.green, c.blue) \
                                    : Palette.nearest_ral(c.red, c.green, c.blue)
        m.color = Sketchup::Color.new(*match[:entry][:rgb])
      end
      model.commit_operation
    end
  end
end
