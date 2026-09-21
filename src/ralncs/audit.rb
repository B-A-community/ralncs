# Анализ материалов модели: для каждого материала подбирает ближайшие
# RAL и NCS, показывает таблицу-ТЗ, умеет копировать её в буфер (для вставки
# в Google Таблицы) и перекрашивать материалы в точные цвета.
# У текстурных материалов цветом считается усреднённый цвет текстуры
# (его отдаёт сам SketchUp через Material#color). Перекраска текстурного
# тонирует текстуру — поэтому она включается отдельной опцией.

require 'json'
require_relative 'lang'
require_relative 'palette'
require_relative 'color_math'

module RALNCS
  module Audit
    PREFS_SECTION = 'RALNCS'
    PREFS_COLUMNS = 'audit_columns'

    module_function

    def show
      model = Sketchup.active_model
      if model.materials.count.zero?
        UI.messagebox(RALNCS.t(:no_materials))
        return
      end

      @dialog&.close
      @dialog = UI::HtmlDialog.new(
        dialog_title: RALNCS.t(:title_audit),
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
      # Настройка столбцов хранится в реестре SketchUp; формат — компактная
      # строка без кавычек (write_default плохо переживает JSON).
      @dialog.add_action_callback('save_columns') do |_ctx, spec|
        Sketchup.write_default(PREFS_SECTION, PREFS_COLUMNS, spec.to_s)
      end

      @dialog.show
    end

    # Собирает все материалы модели и подбирает ближайшие RAL/NCS.
    # Подбор — 2166 расчётов ΔE на цвет, а в реальных моделях сотни материалов
    # с одинаковым цветом, поэтому результат кэшируется по hex.
    def scan
      model = Sketchup.active_model
      rows = []
      cache = {}
      model.materials.each do |m|
        c = m.color
        next unless c

        hex = ColorMath.rgb_to_hex(c.red, c.green, c.blue)
        matches = cache[hex] ||= {
          ral: match_payload(Palette.nearest_ral(c.red, c.green, c.blue)),
          ncs: match_payload(Palette.nearest_ncs(c.red, c.green, c.blue))
        }
        rows << {
          name: m.name,
          display_name: m.display_name,
          hex: hex,
          textured: !m.texture.nil?,
          ral: matches[:ral],
          ncs: matches[:ncs]
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
      payload = scan
      payload[:columns] = Sketchup.read_default(PREFS_SECTION, PREFS_COLUMNS, nil)
      @dialog.execute_script("init(#{payload.to_json})")
    end

    # params: {"palette"=>"ral"|"ncs", "names"=>[...], "tint"=>true/false}
    # Без tint текстурные пропускаются; с tint текстура тонируется в цвет палитры.
    def apply(params)
      model = Sketchup.active_model
      palette_key = params['palette'] == 'ncs' ? :ncs : :ral
      tint = params['tint'] == true

      model.start_operation(RALNCS.t(:op_apply, palette_key.to_s.upcase), true)
      params['names'].each do |name|
        m = model.materials[name]
        next unless m
        next if m.texture && !tint

        c = m.color
        match = palette_key == :ncs ? Palette.nearest_ncs(c.red, c.green, c.blue) \
                                    : Palette.nearest_ral(c.red, c.green, c.blue)
        m.color = Sketchup::Color.new(*match[:entry][:rgb])
      end
      model.commit_operation
    end
  end
end
