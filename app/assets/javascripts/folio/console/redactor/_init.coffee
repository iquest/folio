merge = (xs...) ->
  if xs?.length > 0
    tap {}, (m) -> m[k] = v for k, v of x for x in xs

tap = (o, fn) -> fn(o); o

ADVANCED_OPTIONS =
  plugins: ['imagemanager', 'video', 'table', 'button', 'definedlinks']
  buttons: ['format', 'bold', 'italic', 'deleted']
  imageUploadParam: 'file[file]'
  imageData:
    elements: 'input[name="authenticity_token"]'
    'file[type]': 'Folio::Image'
  imageUpload: '/console/images.json'
  imageManagerJson: '/console/images.json'
  definedlinks: '/console/links.json'
  linkNewTab: true
  pasteLinkTarget: '_blank'
  pastePlainText: true
  linkNofollow: true
  pasteLinks: true
  toolbarFixed: false
  lang: document.documentElement.lang
  formatting: ['p', 'h2', 'h3', 'h4']

OPTIONS =
  plugins: ['table', 'button', 'definedlinks', 'properties']
  buttonsHide: ['file', 'image']
  toolbarFixed: false
  linkNewTab: true
  pasteLinkTarget: '_blank'
  pastePlainText: true
  pasteLinks: true
  definedlinks: '/console/links.json'
  lang: document.documentElement.lang
  formatting: ['p', 'h2', 'h3', 'h4']

window.folioConsoleInitRedactor = (node, options = {}) ->
  redactorOptions = {}
  try
    redactorOptions = JSON.parse(node.dataset.redactorOptions || "{}")
  catch
    redactorOptions = {}
  return if node.classList.contains('redactor-source')
  opts = if options.advanced then ADVANCED_OPTIONS else OPTIONS
  mergedOpts = merge opts, redactorOptions
  $R(node, mergedOpts)

window.folioConsoleDestroyRedactor = (node) ->
  $R(node, 'destroy')

window.folioConsoleRedactorSetContent = (node, content) ->
  R = $R(node)
  R.source.setCode content

window.folioConsoleRedactorGetContent = (node) ->
  R = $R(node)
  R.source.getCode()
