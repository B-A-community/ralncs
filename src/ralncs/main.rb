# Точка входа расширения: меню и панель инструментов.

require 'sketchup.rb'
require_relative 'lang'
require_relative 'fan'
require_relative 'audit'
require_relative 'about'

module RALNCS
  unless file_loaded?(__FILE__)
    icons = File.join(__dir__, 'icons')

    cmd_fan = UI::Command.new(RALNCS.t(:menu_fan)) { Fan.show }
    cmd_fan.tooltip = RALNCS.t(:menu_fan)
    cmd_fan.status_bar_text = RALNCS.t(:tip_fan)
    cmd_fan.small_icon = File.join(icons, 'fan.svg')
    cmd_fan.large_icon = File.join(icons, 'fan.svg')

    cmd_audit = UI::Command.new(RALNCS.t(:menu_audit)) { Audit.show }
    cmd_audit.tooltip = RALNCS.t(:menu_audit)
    cmd_audit.status_bar_text = RALNCS.t(:tip_audit)
    cmd_audit.small_icon = File.join(icons, 'audit.svg')
    cmd_audit.large_icon = File.join(icons, 'audit.svg')

    menu = UI.menu('Extensions').add_submenu('RALNCS')
    menu.add_item(cmd_fan)
    menu.add_item(cmd_audit)
    menu.add_separator
    menu.add_item(RALNCS.t(:menu_about)) { About.show }

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
