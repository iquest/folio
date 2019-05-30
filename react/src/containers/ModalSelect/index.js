import { Component } from 'react'

class ModalSelect extends Component {
  state = {
    el: null,
  }

  componentWillMount () {
    const $ = window.jQuery
    if (!$) return

    $(document).on('click', this.selector(), (e) => {
      this.setState({ el: e.target })
      this.props.loadFiles()
      this.onOpen(e.target)
      this.jQueryModal().modal('show')
    })
  }

  onOpen (el) {
  }

  selector () {
    throw new Error('Not implemented')
  }

  selectingDocument () {
    return this.props.fileType === 'Folio::Document'
  }

  fileTemplate (file, prefix) {
    throw new Error('Not implemented')
  }

  inputName ($el) {
    const $nestedInput = $el.closest('.nested-fields').find('input[type="hidden"]')
    let name
    if ($nestedInput.length) {
      name = $nestedInput.attr('name').match(/\w+\[\w+\]\[\w+\](?:\[\d+\])?/)
    } else {
      const $genericInput = $el.closest('form').find('.form-control[name*="["]').first()
      name = $genericInput.attr('name').split('[')[0]
    }
    return name
  }

  render () {
    return null
  }
}

export default ModalSelect
