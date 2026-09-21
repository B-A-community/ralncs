# Окно «О плагине»: авторы, версия, ссылка на репозиторий.

require_relative 'lang'

module RALNCS
  module About
    REPO_URL = 'https://github.com/B-A-community/ralncs'

    module_function

    def show
      @dialog&.close
      @dialog = UI::HtmlDialog.new(
        dialog_title: RALNCS.t(:title_about),
        preferences_key: 'ralncs_about',
        width: 420,
        height: 300,
        resizable: false,
        style: UI::HtmlDialog::STYLE_DIALOG
      )
      @dialog.set_file(File.join(__dir__, 'html', 'about.html'))
      @dialog.add_action_callback('ready')    { @dialog.execute_script("init(#{{ version: version }.to_json})") }
      @dialog.add_action_callback('open_url') { |_ctx, url| UI.openURL(url) if url == REPO_URL }
      @dialog.add_action_callback('close')    { @dialog.close }
      @dialog.show
    end

    def version
      ext = Sketchup.extensions.find { |e| e.name == 'RALNCS' }
      ext ? ext.version : ''
    end
  end
end
