#= require folio/csrf

$ ->
  $(document).on 'submit', '.folio-newsletter-subscription-form', (e) ->
    e.preventDefault()
    return if window.folioFreshCsrfToken.loading

    $form = $(this)
    return if $form.hasClass('folio-newsletter-subscription-form-submitting')

    $wrap = $form.parent()
    $form.addClass('folio-newsletter-subscription-form-submitting')

    window.folioFreshCsrfToken.withToken (token) ->
      $form
        .find("input[name=\"#{window.folioFreshCsrfToken.tokenParam}\"]")
        .val(token)

      $.post($form.attr('action'), $form.serialize())
      .then (response) ->
        $response = $(response)
        $wrap.replaceWith($response)

        $recaptcha = $response.find('.g-recaptcha')
        if grecaptcha? and $recaptcha.length
          grecaptcha.render $recaptcha[0]

        $response.trigger('folio:submitted')
        if $response.find('.folio-newsletter-subscription-form-message').length
          $response.trigger('folio:success')
        else
          $response.trigger('folio:failure')

      .catch ->
        alert($wrap.data('failure'))
        $wrap.find('input[type="submit"]').prop('disabled', false)
        $wrap.removeClass('folio-newsletter-subscription-form-submitting')
