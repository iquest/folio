import React, { Component } from 'react'
import { connect } from 'react-redux'
import DropzoneComponent from 'react-dropzone-component'

import { CSRF } from 'utils/api'

import Loader from 'components/Loader'
import {
  uploadsSelector,
  addedFile,
  thumbnail,
  success,
  error,
} from 'ducks/uploads'

class MultiSelect extends Component {
  eventHandlers () {
    const { dispatch } = this.props

    return {
      addedfile: (file) => dispatch(addedFile(file)),
      thumbnail: (file, dataUrl) => dispatch(thumbnail(file, dataUrl)),
      success: (file, response) => dispatch(success(file, response)),
      error: (file, message) => dispatch(error(file, message)),
    }
  }

  config () {
    return {
      iconFiletypes: ['.jpg', '.png', '.gif'],
      showFiletypeIcon: false,
      postUrl: this.props.uploads.url,
    }
  }

  djsConfig () {
    return {
      headers: CSRF,
      paramName: 'file[file]',
      previewTemplate: '<span></span>',
      params: {
        'file[type]': this.props.uploads.type,
      }
    }
  }

  render() {
    const { uploads } = this.props
    if (!uploads.url || !uploads.type) return <Loader />

    return (
      <DropzoneComponent
        config={this.config()}
        djsConfig={this.djsConfig()}
        eventHandlers={this.eventHandlers()}
      >
        {this.props.children}
      </DropzoneComponent>
    )
  }
}

const mapStateToProps = (state) => ({
  uploads: uploadsSelector(state),
})

function mapDispatchToProps (dispatch) {
  return { dispatch }
}

export default connect(mapStateToProps, mapDispatchToProps)(MultiSelect)
