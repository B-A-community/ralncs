// Язык интерфейса окон. build.ps1 -Lang en подменяет первую строку.
var LANG = 'ru';

var I18N = {
  ru: {
    // ---- анализ материалов ----
    audit_title: 'RALNCS — анализ материалов',
    all: 'все',
    btn_copy: 'Скопировать ТЗ (в Google Таблицы)',
    btn_apply_ral: 'Применить RAL',
    btn_apply_ncs: 'Применить NCS',
    tint_label: 'тонировать текстурные',
    tint_title: 'Перекрашивать и текстурные материалы: SketchUp затонирует текстуру в цвет палитры',
    btn_cols: 'Столбцы ▾',
    btn_rescan: 'Обновить',
    scanning: 'Считаю ближайшие RAL и NCS для материалов модели…',
    grp_mat: 'Материал',
    col_name: 'Материал', col_type: 'Тип', col_color: 'Цвет', col_hex: 'HEX', col_rgb: 'RGB',
    col_ral_name: 'Название',
    exp_name: 'Материал', exp_type: 'Тип', exp_color: 'Цвет',
    exp_hex_model: 'HEX в модели', exp_rgb_model: 'RGB в модели',
    exp_color_ral: 'Цвет RAL', exp_ral_name: 'Название RAL', exp_ral_hex: 'RAL HEX', exp_ral_rgb: 'RAL RGB', exp_ral_de: 'ΔE RAL',
    exp_color_ncs: 'Цвет NCS', exp_ncs_hex: 'NCS HEX', exp_ncs_rgb: 'NCS RGB', exp_ncs_de: 'ΔE NCS',
    de_excellent: 'отличное совпадение', de_good: 'хорошее совпадение',
    de_notice: 'заметная разница', de_out: 'цвет вне палитры',
    type_tex: 'текстура', type_solid: 'заливка',
    tex_avg: ' — цвет усреднён по текстуре',
    mv_up: 'Выше', mv_down: 'Ниже', mv_left: 'Левее', mv_right: 'Правее',
    cols_hint: 'Порядок сверху вниз = слева направо. Копируются только видимые.',
    cols_reset: 'Сбросить',
    status: 'Материалов: {n} (однотонных {solid}, текстурных {tex})',
    status_tex: ' • у текстурных цвет усреднён по текстуре',
    status_cols: ' • столбцов: {v} из {t}',
    status_de: ' • ΔE — визуальная разница с экранным цветом (меньше — точнее)',
    toast_none: 'Не выбрано ни одного материала',
    toast_nocols: 'Все столбцы скрыты — включите нужные в «Столбцы»',
    toast_copied: 'Скопировано: {r} строк × {c} столбцов. Вставьте в Google Таблицу (Ctrl+V).',
    toast_only_tex: 'Среди выбранных только текстурные материалы — включите «тонировать текстурные», чтобы перекрасить их',
    confirm_apply: 'Перекрасить {n} материал(ов) в точные цвета {p}?',
    confirm_tint: '\nИз них текстурных: {n} — их текстура будет затонирована в цвет {p}.',
    confirm_notint: '\nТекстурные ({n} шт.) не трогаем — включите «тонировать текстурные», если нужно.',
    confirm_undo: '\nДействие можно отменить (Ctrl+Z).',

    // ---- веер ----
    fan_title: 'RALNCS — веер цветов',
    search_ph: 'Поиск: 3020, traffic, 0580-Y80R…',
    pick: 'Выберите цвет',
    btn_mat: 'Создать материал',
    btn_paint: 'Создать и красить',
    fan_footer: 'Цвета показаны в sRGB-приближении для экрана. Мониторы передают цвет по-разному — финальное решение сверяйте с физическим веером RAL/NCS.',
    ral_1: 'RAL 1xxx — жёлтые', ral_2: 'RAL 2xxx — оранжевые', ral_3: 'RAL 3xxx — красные',
    ral_4: 'RAL 4xxx — фиолетовые', ral_5: 'RAL 5xxx — синие', ral_6: 'RAL 6xxx — зелёные',
    ral_7: 'RAL 7xxx — серые', ral_8: 'RAL 8xxx — коричневые', ral_9: 'RAL 9xxx — белые и чёрные',
    ral_other: 'Прочие',
    ncs_neutral: 'Нейтральные (N)', ncs_hue: 'Оттенок ',
    toast_paint: 'Материал создан — инструмент «Заливка» активен',
    toast_mat: 'Материал «{c}» создан',

    // ---- о плагине ----
    about_title: 'О плагине RALNCS',
    about_desc: 'Веер RAL Classic и NCS 1950, подбор ближайших RAL/NCS для материалов модели и ТЗ в один клик.',
    about_authors: 'Авторы',
    about_names: 'Ruslan Tkachenko и Maksar Sanjeev',
    about_ver: 'версия ',
    about_lic: 'Apache 2.0 · B&A community',
    btn_close: 'Закрыть'
  },

  en: {
    audit_title: 'RALNCS — material audit',
    all: 'all',
    btn_copy: 'Copy spec (to Google Sheets)',
    btn_apply_ral: 'Apply RAL',
    btn_apply_ncs: 'Apply NCS',
    tint_label: 'tint textured',
    tint_title: 'Also recolor textured materials: SketchUp tints the texture to the palette color',
    btn_cols: 'Columns ▾',
    btn_rescan: 'Refresh',
    scanning: 'Finding the nearest RAL and NCS for the model materials…',
    grp_mat: 'Material',
    col_name: 'Material', col_type: 'Type', col_color: 'Color', col_hex: 'HEX', col_rgb: 'RGB',
    col_ral_name: 'Name',
    exp_name: 'Material', exp_type: 'Type', exp_color: 'Color',
    exp_hex_model: 'HEX in model', exp_rgb_model: 'RGB in model',
    exp_color_ral: 'RAL color', exp_ral_name: 'RAL name', exp_ral_hex: 'RAL HEX', exp_ral_rgb: 'RAL RGB', exp_ral_de: 'ΔE RAL',
    exp_color_ncs: 'NCS color', exp_ncs_hex: 'NCS HEX', exp_ncs_rgb: 'NCS RGB', exp_ncs_de: 'ΔE NCS',
    de_excellent: 'excellent match', de_good: 'good match',
    de_notice: 'noticeable difference', de_out: 'outside the palette',
    type_tex: 'texture', type_solid: 'solid',
    tex_avg: ' — color averaged from the texture',
    mv_up: 'Up', mv_down: 'Down', mv_left: 'Left', mv_right: 'Right',
    cols_hint: 'Top-to-bottom order = left-to-right. Only visible columns are copied.',
    cols_reset: 'Reset',
    status: 'Materials: {n} ({solid} solid, {tex} textured)',
    status_tex: ' • textured: color averaged from the texture',
    status_cols: ' • columns: {v} of {t}',
    status_de: ' • ΔE — visual difference from the on-screen color (lower is closer)',
    toast_none: 'No materials selected',
    toast_nocols: 'All columns are hidden — enable some under “Columns”',
    toast_copied: 'Copied: {r} rows × {c} columns. Paste into Google Sheets (Ctrl+V).',
    toast_only_tex: 'Only textured materials are selected — enable “tint textured” to recolor them',
    confirm_apply: 'Recolor {n} material(s) to exact {p} colors?',
    confirm_tint: '\n{n} of them are textured — their texture will be tinted to the {p} color.',
    confirm_notint: '\nTextured ({n}) are left untouched — enable “tint textured” if needed.',
    confirm_undo: '\nThis can be undone (Ctrl+Z).',

    fan_title: 'RALNCS — color fan',
    search_ph: 'Search: 3020, traffic, 0580-Y80R…',
    pick: 'Pick a color',
    btn_mat: 'Create material',
    btn_paint: 'Create and paint',
    fan_footer: 'Colors are shown as sRGB approximations for the screen. Monitors differ — verify the final choice against a physical RAL/NCS fan deck.',
    ral_1: 'RAL 1xxx — yellows', ral_2: 'RAL 2xxx — oranges', ral_3: 'RAL 3xxx — reds',
    ral_4: 'RAL 4xxx — violets', ral_5: 'RAL 5xxx — blues', ral_6: 'RAL 6xxx — greens',
    ral_7: 'RAL 7xxx — greys', ral_8: 'RAL 8xxx — browns', ral_9: 'RAL 9xxx — whites and blacks',
    ral_other: 'Other',
    ncs_neutral: 'Neutrals (N)', ncs_hue: 'Hue ',
    toast_paint: 'Material created — Paint Bucket tool is active',
    toast_mat: 'Material “{c}” created',

    about_title: 'About RALNCS',
    about_desc: 'RAL Classic and NCS 1950 color fan, nearest RAL/NCS for every model material, and a one-click color spec.',
    about_authors: 'Authors',
    about_names: 'Ruslan Tkachenko and Maksar Sanjeev',
    about_ver: 'version ',
    about_lic: 'Apache 2.0 · B&A community',
    btn_close: 'Close'
  }
};

var T = I18N[LANG] || I18N.ru;
function t(key) { var s = T[key]; return s === undefined ? key : s; }
// tf('status', {n: 3}) — подстановка {плейсхолдеров}
function tf(key, vars) {
  return t(key).replace(/\{(\w+)\}/g, function (_, k) { return vars[k] !== undefined ? vars[k] : '{' + k + '}'; });
}
// Разметка держит русский текст как запасной; data-t / data-t-title / data-t-ph переводят на месте
function applyLang() {
  document.documentElement.lang = LANG;
  document.querySelectorAll('[data-t]').forEach(function (el) { el.textContent = t(el.getAttribute('data-t')); });
  document.querySelectorAll('[data-t-title]').forEach(function (el) { el.title = t(el.getAttribute('data-t-title')); });
  document.querySelectorAll('[data-t-ph]').forEach(function (el) { el.placeholder = t(el.getAttribute('data-t-ph')); });
  var title = document.querySelector('title[data-t]');
  if (title) document.title = t(title.getAttribute('data-t'));
}
