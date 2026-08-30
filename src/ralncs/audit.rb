# Анализ материалов модели: для каждого однотонного материала подбирает
# ближайшие RAL и NCS, показывает таблицу-ТЗ, умеет копировать TSV
# (для вставки в Google Таблицы) и перекрашивать материалы в точные цвета.

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

    # Собирает однотонные материалы и подбирает ближайшие RAL/NCS.
    def scan
      model = Sketchup.active_model
      rows = []
      skipped = 0
      model.materials.each do |m|
        if m.texture
          skipped += 1
          next
        end
        c = m.color
        ral = Palette.nearest_ral(c.red, c.green, c.blue)
        ncs = Palette.nearest_ncs(c.red, c.green, c.blue)
        rows << {
          name: m.name,
          display_name: m.display_name,
          hex: ColorMath.rgb_to_hex(c.red, c.green, c.blue),
          ral: match_payload(ral),
          ncs: match_payload(ncs)
        }
      end
      { rows: rows.sort_by { |r| r[:display_name].downcase }, skipped: skipped }
    end

    def match_payload(match)
      e = match[:entry]
      { code: e[:code], name: e[:name], hex: e[:hex], de: match[:de].round(1) }
    end

    def push_data
      @dialog.execute_script("init(#{scan.to_json})")
    end

    # params: {"palette"=>"ral"|"ncs", "rename"=>true/false, "names"=>[...]}
    def apply(params)
      model = Sketchup.active_model
      palette_key = params['palette'] == 'ncs' ? :ncs : :ral
      rename = params['rename']

      model.start_operation("RALNCS: применить #{palette_key.to_s.upcase}", true)
      params['names'].each do |name|
        m = model.materials[name]
        next unless m && m.texture.nil?

        c = m.color
        match = palette_key == :ncs ? Palette.nearest_ncs(c.red, c.green, c.blue) \
                                    : Palette.nearest_ral(c.red, c.green, c.blue)
        entry = match[:entry]
        m.color = Sketchup::Color.new(*entry[:rgb])
        rename_material(model, m, entry) if rename
      end
      model.commit_operation
    end

    def rename_material(model, material, entry)
      desired = [entry[:code], entry[:name]].compact.join(' ')
      return if material.name == desired

      # Имена материалов уникальны: при конфликте добавляем суффикс.
      candidate = desired
      i = 2
      while (other = model.materials[candidate]) && other != material
        candidate = "#{desired} (#{i})"
        i += 1
      end
      material.name = candidate
    rescue ArgumentError
      nil # не удалось переименовать — цвет уже применён, этого достаточно
    end
  end
end
