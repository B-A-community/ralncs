# Панель инструментов + меню в стиле B&A: SVG-иконки, подсказки, статус-бар.
# Один и тот же svg для small_icon и large_icon. При первом запуске панель
# показывается сама, дальше уважаем выбор пользователя.
module MyPlugin
  unless file_loaded?(__FILE__)
    icons = File.join(__dir__, 'icons')

    cmd_main = UI::Command.new('Главное действие') { MyPlugin::Main.show }
    cmd_main.tooltip = 'Главное действие'
    cmd_main.status_bar_text = 'Одна фраза: что делает и с чем работает'
    cmd_main.small_icon = File.join(icons, 'main.svg')
    cmd_main.large_icon = File.join(icons, 'main.svg')

    menu = UI.menu('Extensions').add_submenu('MyPlugin')
    menu.add_item(cmd_main)

    toolbar = UI::Toolbar.new('MyPlugin')
    toolbar.add_item(cmd_main)
    case toolbar.get_last_state
    when TB_NEVER_SHOWN then toolbar.show
    when TB_VISIBLE then toolbar.restore
    end

    file_loaded(__FILE__)
  end
end
