optionMapper = (str) -> { value: str }

makeItems = (string) ->
  if string
    string.split(', ').map(optionMapper)
  else
    []

init = ->
  $inputs = $('.folio-console-tagsinput').not('.folio-console-selectize--bound')
  return if $inputs.length is 0

  $inputs.each ->
    $this = $(this)
    $formGroup = $this.closest('.form-group')

    if $formGroup.data('allow-create')
      createOption = optionMapper
    else
      createOption = false

    $this.selectize
      dropdownParent: 'body'
      labelField: 'value'
      searchField: 'value'
      delimiter: ', '
      plugins: ['remove_button']
      create: createOption
      maxOptions: 50000
      preload: 'focus'
      onChange: (_value) ->
        $this.trigger('change')
      load: (q, callback) ->
        $.ajax
          url: '/console/api/tags/react_select'
          method: 'GET'
          data:
            q: q
            context: $this.data('context')
          error: ->
            callback()
          success: (res) ->
            callback(res.data.map(optionMapper))
      render:
        option_create: (data, escape) ->
          """
            <div class="create">
              #{window.FolioConsole.translations.add}
              <strong>#{escape(data.input)}</strong>&hellip;
            </div>
          """

dispose = ->
  $('.folio-console-tagsinput').each ->
    @selectize?.destroy()

if Turbolinks?
  $(document)
    .on 'turbolinks:load', init
    .on 'turbolinks:before-cache', dispose

else
  $ init
