# Язык Ruby-части (меню, заголовки окон, сообщения). build.ps1 -Lang en
# подменяет строку LANG; окна берут язык из html/i18n.js (там та же подмена).

module RALNCS
  LANG = 'ru'

  STRINGS = {
    'ru' => {
      ext_description: 'Палитры RAL Classic и NCS 1950: веер цветов, покраска и ' \
                       'автоматический подбор ближайших RAL/NCS для материалов модели (ТЗ).',
      menu_fan:        'Веер RAL / NCS',
      tip_fan:         'Палитры RAL Classic и NCS 1950: выбор цвета, создание материала, покраска',
      menu_audit:      'Анализ материалов (ТЗ)',
      tip_audit:       'Подбор ближайших RAL/NCS для материалов модели и экспорт ТЗ',
      menu_about:      'О плагине…',
      title_about:     'О плагине RALNCS',
      title_audit:     'RALNCS — анализ материалов (ТЗ)',
      title_fan:       'RALNCS — веер цветов',
      no_materials:    'В модели нет материалов.',
      op_apply:        'RALNCS: применить %s',
      op_create:       'RALNCS: создать материал'
    },
    'en' => {
      ext_description: 'RAL Classic and NCS 1950 palettes: color fan, painting and ' \
                       'automatic nearest RAL/NCS matching for model materials (color spec).',
      menu_fan:        'RAL / NCS fan',
      tip_fan:         'RAL Classic and NCS 1950 palettes: pick a color, create a material, paint',
      menu_audit:      'Material audit (spec)',
      tip_audit:       'Nearest RAL/NCS for model materials and spec export',
      menu_about:      'About…',
      title_about:     'About RALNCS',
      title_audit:     'RALNCS — material audit (spec)',
      title_fan:       'RALNCS — color fan',
      no_materials:    'The model has no materials.',
      op_apply:        'RALNCS: apply %s',
      op_create:       'RALNCS: create material'
    }
  }.freeze

  def self.t(key, *args)
    s = (STRINGS[LANG] || STRINGS['ru'])[key] || STRINGS['ru'][key] || key.to_s
    args.empty? ? s : format(s, *args)
  end
end
