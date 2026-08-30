# Точка входа расширения: меню и панель инструментов.

require 'sketchup.rb'
require_relative 'fan'
require_relative 'audit'

module RALNCS
  unless file_loaded?(__FILE__)
    icons = File.join(__dir__, 'icons')

    cmd_fan = UI::Command.new('Веер RAL / NCS') { Fan.show }
    cmd_fan.tooltip = 'Веер RAL / NCS'
    cmd_fan.status_bar_text = 'Палитры RAL Classic и NCS 1950: выбор цвета, создание материала, покраска'
    cmd_fan.small_icon = File.join(icons, 'fan.svg')
    cmd_fan.large_icon = File.join(icons, 'fan.svg')

    cmd_audit = UI::Command.new('Анализ материалов (ТЗ)') { Audit.show }
    cmd_audit.tooltip = 'Анализ материалов (ТЗ)'
    cmd_audit.status_bar_text = 'Подбор ближайших RAL/NCS для однотонных материалов модели и экспорт ТЗ'
    cmd_audit.small_icon = File.join(icons, 'audit.svg')
    cmd_audit.large_icon = File.join(icons, 'audit.svg')

    menu = UI.menu('Extensions').add_submenu('RALNCS')
    menu.add_item(cmd_fan)
    menu.add_item(cmd_audit)

    toolbar = UI::Toolbar.new('RALNCS')
    toolbar.add_item(cmd_fan)
    toolbar.add_item(cmd_audit)
    # При первом запуске показываем панель, дальше уважаем выбор пользователя.
    case toolbar.get_last_state
    when TB_NEVER_SHOWN then toolbar.show
    when TB_VISIBLE then toolbar.restore
    end

    file_loaded(__FILE__)
  end
end
