import { mapValues, sortBy, omit } from 'lodash'
import { takeEvery, call, select, put } from 'redux-saga/effects'

import { apiHtmlPost, apiPost } from 'utils/api'
import arrayMove from 'utils/arrayMove'
import timestamp from 'utils/timestamp'

import { setOriginalPlacements } from 'ducks/filePlacements'

// Constants

const SET_ATOMS_DATA = 'atoms/SET_ATOMS_DATA'
const NEW_ATOM = 'atoms/NEW_ATOM'
const EDIT_ATOM = 'atoms/EDIT_ATOM'
const REMOVE_ATOM = 'atoms/REMOVE_ATOM'
const VALIDATE_AND_SAVE_FORM_ATOM = 'atoms/VALIDATE_AND_SAVE_FORM_ATOM'
const SAVE_FORM_ATOM = 'atoms/SAVE_FORM_ATOM'
const CLOSE_FORM_ATOM = 'atoms/CLOSE_FORM_ATOM'
const UPDATE_FORM_ATOM_TYPE = 'atoms/UPDATE_FORM_ATOM_TYPE'
const UPDATE_FORM_ATOM_VALUE = 'atoms/UPDATE_FORM_ATOM_VALUE'
const MOVE_ATOM_TO_INDEX = 'atoms/MOVE_ATOM_TO_INDEX'
const UPDATE_FORM_ATOM_ATTACHMENTS = 'atoms/UPDATE_FORM_ATOM_ATTACHMENTS'
const REMOVE_FORM_ATOM_ATTACHMENT = 'atoms/REMOVE_FORM_ATOM_ATTACHMENT'
const SET_FORM_ATOM_FILE_PLACEMENTS = 'atoms/SET_FORM_ATOM_FILE_PLACEMENTS'
const SET_FORM_VALIDATION_ERRORS = 'atoms/SET_FORM_VALIDATION_ERRORS'
const UPDATE_FORM_ATOM_ASSOCIATION = 'atoms/UPDATE_FORM_ATOM_ASSOCIATION'

// Actions

export function setAtomsData (data) {
  return { type: SET_ATOMS_DATA, data }
}

export function updateFormAtomType (newType, values) {
  return { type: UPDATE_FORM_ATOM_TYPE, newType, values }
}

export function updateFormAtomValue (key, value) {
  return { type: UPDATE_FORM_ATOM_VALUE, key, value }
}

export function newAtom (rootKey, index, atomType) {
  return { type: NEW_ATOM, rootKey, index, atomType }
}

export function editAtom (rootKey, index) {
  return { type: EDIT_ATOM, rootKey, index }
}

export function removeAtom (rootKey, index) {
  return { type: REMOVE_ATOM, rootKey, index }
}

export function moveAtomToIndex (rootKey, index, targetIndex) {
  return { type: MOVE_ATOM_TO_INDEX, rootKey, index, targetIndex }
}

export function closeFormAtom () {
  return { type: CLOSE_FORM_ATOM }
}

export function validateAndSaveFormAtom (filePlacements) {
  return { type: VALIDATE_AND_SAVE_FORM_ATOM, filePlacements }
}

export function saveFormAtom (filePlacements) {
  return { type: SAVE_FORM_ATOM, filePlacements }
}

export function updateFormAtomAttachments (attachmentKey, data) {
  return { type: UPDATE_FORM_ATOM_ATTACHMENTS, attachmentKey, data }
}

export function removeFormAtomAttachment (attachmentKey) {
  return { type: REMOVE_FORM_ATOM_ATTACHMENT, attachmentKey }
}

export function setFormAtomFilePlacements () {
  return { type: SET_FORM_ATOM_FILE_PLACEMENTS }
}

export function setFormValidationErrors (formSubstate) {
  return { type: SET_FORM_VALIDATION_ERRORS, formSubstate }
}

export function updateFormAtomAssociation (associationKey, record) {
  return { type: UPDATE_FORM_ATOM_ASSOCIATION, associationKey, record }
}

// Selectors

export const atomsSelector = (state) => ({
  ...state.atoms,
  atoms: mapValues(state.atoms.atoms, (collection) => (
    collection.map((atom) => ({
      ...atom,
      meta: state.atoms.structures[atom.type]
    }))
  ))
})

export const atomsFormSelector = (state) => state.atoms.form

export const atomSelector = (substate, rootKey, index) => {
  const atom = substate.atoms[rootKey][index]

  return {
    ...atom,
    meta: substate.structures[atom.type]
  }
}

export const atomTypesSelector = (state) => {
  const unsorted = Object.keys(state.atoms.structures).map((key) => ({
    key,
    title: state.atoms.structures[key].title
  }))
  return sortBy(unsorted, ['title'])
}

const serializeAtom = (state, atom) => {
  const base = {
    ...omit(atom, ['associations']),
    ...omit(atom.data, ['placement_id']),
    ...atom.associations,
    placement_type: state.atoms.placementType
  }

  Object.keys(base).forEach((key) => {
    if (base[key] === '<p></p>') base[key] = null
  })

  state.atoms.structures[atom.type]['attachments'].forEach(({ key, plural }) => {
    if (!base[key]) return
    if (plural) {
      base[key] = base[key].map((fp) => omit(fp, ['id', 'file']))
    } else {
      base[key] = omit(base[key], ['id', 'file'])
    }
  })

  return omit(base, ['meta', 'timestamp', 'data'])
}

export const serializedAtomsSelector = (state) => {
  const h = {}
  Object.keys(state.atoms.atoms).forEach((rootKey) => {
    h[`${rootKey}_attributes`] = state.atoms.atoms[rootKey].map((atom) => serializeAtom(state, atom))
  })
  return h
}

export const makeSerializedFormAtomSelector = (action) => (state) => {
  return serializeAtom(state, {
    ...state.atoms.form.atom,
    ...action.filePlacements,
    placement_type: state.atoms.placementType
  })
}

// Sagas
function * updateAtomPreviews (action) {
  yield put(closeFormAtom())
  const $ = window.jQuery
  const $iframes = $('.f-c-simple-form-with-atoms__iframe')
  $iframes.each((_i, iframe) => {
    $(iframe).parent().addClass('f-c-simple-form-with-atoms__preview--loading')
  })
  const serializedAtoms = yield select(serializedAtomsSelector)

  const $labels = $('.f-c-js-atoms-placement-label')
  if ($labels.length) {
    serializedAtoms['labels'] = {}
    $labels.each((i, label) => {
      const $label = $(label)
      serializedAtoms['labels'][$label.data('locale') || null] = $label.val()
    })
  }
  const $perexes = $('.f-c-js-atoms-placement-perex')
  if ($perexes.length) {
    serializedAtoms['perexes'] = {}
    $perexes.each((i, perex) => {
      const $perex = $(perex)
      serializedAtoms['perexes'][$perex.data('locale') || null] = $perex.val()
    })
  }

  const html = yield (call(apiHtmlPost, '/console/atoms/preview', serializedAtoms))
  $iframes.each((_i, iframe) => {
    const callback = () => {
      if (!iframe.contentWindow.jQuery) { return setTimeout(callback, 100) }
      const $iframe = $(iframe)
      const visibleLocale = $iframe.closest('.f-c-simple-form-with-atoms__preview').find('.f-c-atoms-locale-switch__button--active').data('locale')
      const $body = iframe.contentWindow.jQuery(iframe.contentDocument.body)
      $body.html(html)
      $body.find('.f-c-atoms-previews__locale').each((_i, el) => {
        const $el = iframe.contentWindow.jQuery(el)
        $el.prop('hidden', $el.data('locale') && $el.data('locale') !== visibleLocale)
      })
      iframe.contentWindow.postMessage({ type: 'replacedHtml' }, window.origin)
      $(iframe).parent().removeClass('f-c-simple-form-with-atoms__preview--initializing f-c-simple-form-with-atoms__preview--loading')
    }
    callback()
  })
  if (action.type !== SET_ATOMS_DATA) {
    window.postMessage({ type: 'setFormAsDirty' }, window.origin)
  }
}

function * updateAtomPreviewsSaga () {
  yield [
    takeEvery(REMOVE_ATOM, updateAtomPreviews),
    takeEvery(MOVE_ATOM_TO_INDEX, updateAtomPreviews),
    takeEvery(SAVE_FORM_ATOM, updateAtomPreviews),
    takeEvery(SET_ATOMS_DATA, updateAtomPreviews)
  ]
}

function * showAtomsForm (action) {
  window.jQuery('.f-c-simple-form-with-atoms').addClass('f-c-simple-form-with-atoms--editing-atom')
  yield put(setFormAtomFilePlacements())
}

function * showAtomsFormSaga () {
  yield [
    takeEvery(NEW_ATOM, showAtomsForm),
    takeEvery(EDIT_ATOM, showAtomsForm)
  ]
}

function * hideAtomsForm (action) {
  yield window.jQuery('.f-c-simple-form-with-atoms').removeClass('f-c-simple-form-with-atoms--editing-atom')
}

function * hideAtomsFormSaga () {
  yield takeEvery(CLOSE_FORM_ATOM, hideAtomsForm)
}

function * setAtomFilePlacements (action) {
  const form = yield select(atomsFormSelector)
  yield put(setOriginalPlacements('images', form.atom.image_placements_attributes || []))
  yield put(setOriginalPlacements('documents', form.atom.document_placement_attributes || []))
}

function * setAtomFilePlacementsSaga () {
  yield takeEvery(SET_FORM_ATOM_FILE_PLACEMENTS, setAtomFilePlacements)
}

function * validateAndSaveFormAtomPerform (action) {
  const serializedForm = yield select(makeSerializedFormAtomSelector(action))
  const response = yield (call(apiPost, '/console/atoms/validate', serializedForm))
  if (response.valid) {
    yield put(saveFormAtom(action.filePlacements))
  } else {
    yield put(setFormValidationErrors(response))
  }
}

function * validateAndSaveFormAtomSaga () {
  yield takeEvery(VALIDATE_AND_SAVE_FORM_ATOM, validateAndSaveFormAtomPerform)
}

export const atomsSagas = [
  updateAtomPreviewsSaga,
  showAtomsFormSaga,
  hideAtomsFormSaga,
  setAtomFilePlacementsSaga,
  validateAndSaveFormAtomSaga
]

// State

export const initialState = {
  atoms: {},
  destroyedIds: {},
  namespace: null,
  structures: {},
  placementType: null,
  form: {
    dirty: false,
    rootKey: null,
    index: null,
    atom: null,
    edit: null,
    valid: null,
    validating: false,
    errors: {},
    messages: []
  }
}

// Reducer

function atomsReducer (state = initialState, action) {
  switch (action.type) {
    case SET_ATOMS_DATA: {
      const atoms = {}
      let i = 1
      Object.keys(action.data.atoms).forEach((atomsKey) => {
        atoms[atomsKey] = action.data.atoms[atomsKey].map((atom) => {
          const timestamp = i += 1
          return {
            ...atom,
            timestamp: timestamp
          }
        })
      })

      return {
        ...state,
        ...action.data,
        atoms
      }
    }

    case NEW_ATOM:
      return {
        ...state,
        form: {
          ...initialState.form,
          rootKey: action.rootKey,
          index: action.index,
          edit: false,
          atom: {
            id: null,
            type: action.atomType,
            data: {},
            timestamp: timestamp(),
            meta: state.structures[action.atomType],
            associations: {}
          }
        }
      }

    case EDIT_ATOM:
      return {
        ...state,
        form: {
          ...initialState.form,
          rootKey: action.rootKey,
          index: action.index,
          atom: atomSelector(state, action.rootKey, action.index),
          edit: true
        }
      }

    case REMOVE_ATOM: {
      const atom = state.atoms[action.rootKey][action.index]

      if (atom.id) {
        return {
          ...state,
          destroyedIds: {
            ...state.destroyedIds,
            [action.rootKey]: [...state.destroyedIds[action.rootKey], atom.id]
          },
          atoms: {
            ...state.atoms,
            [action.rootKey]: state.atoms[action.rootKey].filter((a, i) => i !== action.index)
          }
        }
      } else {
        return {
          ...state,
          atoms: {
            ...state.atoms,
            [action.rootKey]: state.atoms[action.rootKey].filter((atom, i) => i !== action.index)
          }
        }
      }
    }

    case CLOSE_FORM_ATOM:
      return {
        ...state,
        form: {
          ...initialState.form
        }
      }

    case SAVE_FORM_ATOM: {
      const destroyedIds = { ...state.destroyedIds }

      if (state.form.edit) {
        destroyedIds[state.form.rootKey] = [...state.destroyedIds[state.form.rootKey], state.form.atom.id]
      }

      let atoms = []
      const newAtom = {
        ...omit(state.form.atom, ['meta', 'id']),
        ...action.filePlacements,
        timestamp: timestamp()
      }

      if (state.form.index < state.atoms[state.form.rootKey].length) {
        state.atoms[state.form.rootKey].forEach((atom, index) => {
          if (index === state.form.index) {
            atoms.push(newAtom)

            if (!state.form.edit) {
              atoms.push(atom)
            }
          } else {
            atoms.push(atom)
          }
        })
      } else {
        atoms = [
          ...state.atoms[state.form.rootKey],
          newAtom
        ]
      }

      return {
        ...state,
        destroyedIds,
        atoms: {
          ...state.atoms,
          [state.form.rootKey]: atoms
        },
        form: {
          ...initialState.form
        }
      }
    }

    case VALIDATE_AND_SAVE_FORM_ATOM:
      return {
        ...state,
        form: {
          ...state.form,
          validating: true
        }
      }

    case UPDATE_FORM_ATOM_TYPE:
      return {
        ...state,
        form: {
          ...state.form,
          dirty: true,
          atom: {
            ...state.form.atom,
            associations: {},
            type: action.newType,
            data: action.values,
            meta: state.structures[action.newType]
          }
        }
      }

    case UPDATE_FORM_ATOM_VALUE:
      return {
        ...state,
        form: {
          ...state.form,
          dirty: true,
          atom: {
            ...state.form.atom,
            data: {
              ...state.form.atom.data,
              [action.key]: action.value
            }
          }
        }
      }

    case MOVE_ATOM_TO_INDEX:
      return {
        ...state,
        atoms: {
          ...state.atoms,
          [action.rootKey]: arrayMove(state.atoms[action.rootKey], action.index, action.targetIndex)
        }
      }

    case UPDATE_FORM_ATOM_ATTACHMENTS: {
      return {
        ...state,
        form: {
          ...state.form,
          atom: {
            ...state.form.atom,
            [action.attachmentKey]: {
              ...state.form.atom[action.attachmentKey],
              ...action.data
            }
          }
        }
      }
    }

    case REMOVE_FORM_ATOM_ATTACHMENT: {
      return {
        ...state,
        form: {
          ...state.form,
          atom: omit(state.form.atom, [action.attachmentKey])
        }
      }
    }

    case SET_FORM_VALIDATION_ERRORS: {
      return {
        ...state,
        form: {
          ...state.form,
          ...action.formSubstate,
          validating: false
        }
      }
    }

    case UPDATE_FORM_ATOM_ASSOCIATION: {
      return {
        ...state,
        form: {
          ...state.form,
          atom: {
            ...state.form.atom,
            associations: {
              ...state.form.atom.associations,
              [action.associationKey]: action.record
            }
          }
        }
      }
    }

    default:
      return state
  }
}

export default atomsReducer