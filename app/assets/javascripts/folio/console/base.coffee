#= require jquery
#= require jquery_ujs
#= require popper
#= require bootstrap-sprockets

#= require cocoon
#= require redactor

#= require ./redactor-imagemanager

#= require ./redactor-init

#= require folio/cable
#= require folio/console/_data-auto-submit
#= require folio/console/_data-change-value
#= require folio/console/_data-destroy-association
#= require folio/console/_data-cocoon-single-nested
#= require folio/console/_bootstrap-tabs-lazyload
#= require folio/console/_cocoon-set-position
#= require folio/console/atom_form_fields/atom_form_fields
#= require folio/console/tagsinput/tagsinput
#= require folio/console/nested_model_controls/nested_model_controls
#= require folio/console/boolean_toggle/boolean_toggle

#= require ./nodes_table

#= require folio/console/main_app

$ ->
  $(document).on 'change', '#filter-form', ->
    $(this).submit()

  switchRows = (this_node, that_node) ->
    this_pos = this_node.find('input#node_position').val()
    that_pos = that_node.find('input#node_position').val()
    this_node.find('input#node_position').val(that_pos)
    that_node.find('input#node_position').val(this_pos)
    this_node_id = this_node.find('input#node_id').val()
    this_node_children = this_node.nextAll("tr[data-parent='#{this_node_id}']")
    that_node_id = that_node.find('input#node_id').val()
    that_node_children = that_node.nextAll("tr[data-parent='#{that_node_id}']")
    this_node.after(that_node)

    if this_node_children
      moveChildrenRows(this_node, this_node_children)
    if that_node_children
      moveChildrenRows(that_node, that_node_children)

  moveChildrenRows = (node, children) ->
    last_row = node
    children.each ->
      $t = $(this)
      last_row.after($t)
      last_row = $t

  switchModelPositions = (this_row, that_row, url) ->
    return if that_row.length == 0

    pos = Number(this_row.find('input#model_position').val())
    data = {}
    data[this_row.find('input#model_id').val()] = { position: pos - 1 }
    data[that_row.find('input#model_id').val()] = { position: pos }

    $.ajax
      type: "POST"
      url: url
      data: { ids: data }
      success: (e) ->
        switchRows(this_row, that_row, url)
        return

  $(document).on 'click', '.btn.custom-model.position-up', ->
    $button = $(this)
    $this_row = $button.closest('tr')
    $that_row = $this_row.prevAll("tr:first")
    url = $button.data('url')

    switchModelPositions($this_row, $that_row, url)

  $(document).on 'click', '.btn.custom-model.position-down', ->
    $button = $(this)
    $this_row = $button.closest('tr')
    $that_row = $this_row.nextAll("tr:first")
    url = $button.data('url')

    switchModelPositions($that_row, $this_row, url)

  $(document).on 'click', '.btn.node.position-up', ->
    $this_node = $(this).closest('tr')
    $that_node = $this_node.prevAll("tr[data-parent='#{$this_node.data('parent')}'][data-depth='#{$this_node.data('depth')}']:first")

    url = '/console/nodes/set_positions.json'
    switchModelPositions($this_node, $that_node, url, 'node')

  $(document).on 'click', '.btn.node.position-down', ->
    $this_node = $(this).closest('tr')
    $that_node = $this_node.nextAll("tr[data-parent='#{$this_node.data('parent')}'][data-depth='#{$this_node.data('depth')}']:first")

    url = '/console/nodes/set_positions.json'
    switchModelPositions($that_node, $this_node, url, 'node')
