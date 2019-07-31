# frozen_string_literal: true

module Folio
  module Console::ReactHelper
    def react_images(selected_placements = nil,
                     attachmentable: 'page',
                     type: :image_placements)
      react_files('Folio::Image',
                  selected_placements,
                  attachmentable: attachmentable,
                  type: type)
    end

    def react_documents(selected_placements = nil,
                        attachmentable: 'page',
                        type: :document_placements)
      react_files('Folio::Document',
                  selected_placements,
                  attachmentable: attachmentable,
                  type: type)
    end

    def react_picker(f, placement_key, file_type: 'Folio::Image', title: nil)
      raw cell('folio/console/react_picker', f, placement_key: placement_key,
                                                title: title,
                                                file_type: file_type)
    end

    def react_modal_for(file_type, single: true)
      if ['new', 'edit', 'create', 'update'].include?(action_name)
        mode = single ? 'modal-single-select' : 'modal-multi-select'

        content_tag(:div, nil,
          'class': 'folio-react-wrap',
          'data-file-type': file_type,
          'data-mode': mode,
        )
      end
    end

    def console_form_atoms(f)
      if f.object.class.respond_to?(:atom_locales)
        atoms = {}
        destroyed_ids = {}
        f.object.class.atom_locales.each do |locale|
          key = "#{locale}_atoms"
          atoms[key] = f.object.send(key).to_a.map(&:to_h)
          destroyed_ids[key] = []
        end
      else
        atoms = { atoms: f.object.atoms.to_a.map(&:to_h) }
        destroyed_ids = { atoms: [] }
      end

      if f.lookup_model_names.size == 1
        namespace = f.lookup_model_names[0]
      else
        nested = f.lookup_model_names[1..-1].map { |n| "[#{n}]" }
        namespace = "#{f.lookup_model_names[0]}#{nested.join('')}"
      end

      data = {
        atoms: atoms,
        destroyedIds: destroyed_ids,
        namespace: namespace,
        structures: Folio::Atom.structures,
      }

      content_tag(:div, nil, 'class': 'f-c-atoms folio-react-wrap',
                             'data-mode': 'atoms',
                             'data-atoms': data.to_json)
    end

    private

      def react_files(file_type, selected_placements, attachmentable:, type:)
        if selected_placements.present?
          placements = selected_placements.ordered.map do |fp|
            {
              id: fp.id,
              file_id: fp.file.id,
              alt: fp.alt,
              title: fp.title,
            }
          end.to_json
        else
          placements = nil
        end

        content_tag(:div, nil,
          'class': 'folio-react-wrap',
          'data-original-placements': placements,
          'data-file-type': file_type,
          'data-mode': 'multi-select',
          'data-attachmentable': attachmentable,
          'data-placement-type': type,
        )
      end
  end
end
