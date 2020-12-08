ADVANCED_OPTIONS =
  plugins: ['video', 'table', 'button', 'character_counter']
  toolbarFixed: true
  lang: document.documentElement.lang
  formatting: ['p', 'h2', 'h3', 'h4']
  linkNewTab: true

OPTIONS =
  plugins: ['table', 'button', 'character_counter']
  buttonsHide: ['file', 'image']
  toolbarFixed: true
  lang: document.documentElement.lang
  formatting: ['p', 'h2', 'h3', 'h4']
  linkNewTab: true

EMAIL_OPTIONS =
  plugins: ['button', 'character_counter']
  buttonsHide: ['file', 'image', 'format', 'deleted', 'lists']
  toolbarFixed: true
  lang: document.documentElement.lang
  formatting: []

window.folioConsoleInitRedactor = (node, options = {}, additional = {}) ->
  return if node.classList.contains('redactor-source')

  if options.advanced
    opts = ADVANCED_OPTIONS
  else if options.email
    opts = EMAIL_OPTIONS
  else
    opts = OPTIONS

  $R(node, $.extend({}, opts, additional))

window.folioConsoleDestroyRedactor = (node) ->
  $R(node, 'destroy')

window.folioConsoleRedactorSetContent = (node, content) ->
  R = $R(node)
  R.source.setCode content

window.folioConsoleRedactorGetContent = (node) ->
  R = $R(node)
  R.source.getCode()
