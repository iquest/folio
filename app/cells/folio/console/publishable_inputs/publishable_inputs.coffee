$(document).on 'change', '.f-c-publishable-inputs__checkbox', ->
  $this = $(this)
  $parent = $this.closest('.f-c-publishable-inputs__box')
  $parent.toggleClass('f-c-publishable-inputs__box--active', @checked)

  if @checked and $parent.hasClass('f-c-publishable-inputs__box--date')
    $input = $parent.find('.f-c-publishable-inputs__input')
    unless $input.val()
      format = $input.data('DateTimePicker').options().format
      now = moment()
      $input.val now.format(format)
      $input.data(now.format())