# HtmlDialog в стиле B&A: данные — после колбэка ready через execute_script,
# изменения модели — одной операцией (Ctrl+Z снимает всё разом),
# настройки — в реестре компактной строкой без кавычек.
require 'json'

module MyPlugin
  module Main
    PREFS_SECTION = 'MyPlugin'

    module_function

    def show
      @dialog&.close
      @dialog = UI::HtmlDialog.new(
        dialog_title: 'MyPlugin — окно',
        preferences_key: 'myplugin_main',   # SketchUp запомнит размер и положение
        width: 980, height: 640,
        style: UI::HtmlDialog::STYLE_DIALOG
      )
      @dialog.set_file(File.join(__dir__, 'html', 'main.html'))

      @dialog.add_action_callback('ready')  { push_data }
      @dialog.add_action_callback('rescan') { push_data }
      @dialog.add_action_callback('apply') do |_ctx, json|
        apply(JSON.parse(json))
        push_data
      end
      # write_default плохо переживает JSON с кавычками — храним строку вида "a:1,-b|c:2"
      @dialog.add_action_callback('save_prefs') do |_ctx, spec|
        Sketchup.write_default(PREFS_SECTION, 'prefs', spec.to_s)
      end

      @dialog.show
    end

    def push_data
      payload = scan                       # тяжёлая работа здесь; в html до этого висит «Считаю…»
      payload[:prefs] = Sketchup.read_default(PREFS_SECTION, 'prefs', nil)
      @dialog.execute_script("init(#{payload.to_json})")
    end

    def scan
      { rows: [] }
    end

    def apply(params)
      model = Sketchup.active_model
      model.start_operation('MyPlugin: применить', true)
      # ... изменения модели ...
      model.commit_operation
    end
  end
end
