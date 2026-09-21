# Веер RAL / NCS: браузер палитр с экранными (sRGB) эквивалентами цветов.
# Клик по цвету — создание материала и, по желанию, сразу инструмент «Заливка».

require 'json'
require_relative 'lang'
require_relative 'palette'

module RALNCS
  module Fan
    module_function

    def show
      @dialog&.close
      @dialog = UI::HtmlDialog.new(
        dialog_title: RALNCS.t(:title_fan),
        preferences_key: 'ralncs_fan',
        width: 900,
        height: 660,
        style: UI::HtmlDialog::STYLE_DIALOG
      )
      @dialog.set_file(File.join(__dir__, 'html', 'fan.html'))

      @dialog.add_action_callback('ready') do
        payload = {
          ral: Palette.ral.map { |e| slim(e) },
          ncs: Palette.ncs.map { |e| slim(e) }
        }
        @dialog.execute_script("init(#{payload.to_json})")
      end

      @dialog.add_action_callback('make_material') do |_ctx, json|
        make_material(JSON.parse(json))
      end

      @dialog.show
    end

    def slim(entry)
      { code: entry[:code], name: entry[:name], hex: entry[:hex], rgb: entry[:rgb] }
    end

    # params: {"code"=>..., "name"=>..., "hex"=>..., "rgb"=>[r,g,b], "paint"=>bool}
    def make_material(params)
      model = Sketchup.active_model
      name = [params['code'], params['name']].compact.join(' ')

      materials = model.materials
      m = materials[name]
      unless m
        model.start_operation(RALNCS.t(:op_create), true)
        m = materials.add(name)
        m.color = Sketchup::Color.new(*params['rgb'])
        model.commit_operation
      end

      materials.current = m
      Sketchup.send_action('selectPaintTool:') if params['paint']
    end
  end
end
