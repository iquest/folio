# frozen_string_literal: true

module Folio
  module Console::ReactHelper
    def react_images(selected_placements = nil,
                     attachmentable: 'page',
                     type: :image_placements,
                     atom_setting: nil)
      react_files('Folio::Image',
                  selected_placements,
                  attachmentable: attachmentable,
                  type: type,
                  atom_setting: atom_setting)
    end

    def react_documents(selected_placements = nil,
                        attachmentable: 'page',
                        type: :document_placements,
                        atom_setting: nil)
      react_files('Folio::Document',
                  selected_placements,
                  attachmentable: attachmentable,
                  type: type,
                  atom_setting: atom_setting)
    end

    def react_picker(f, placement_key, file_type: 'Folio::Image', title: nil)
      @output_react_meta_data = true

      raw cell('folio/console/react_picker', f, placement_key: placement_key,
                                                title: title,
                                                file_type: file_type)
    end

    def react_ancestry(klass, max_nesting_depth: 2)
      raw cell('folio/console/react_ancestry',
               klass,
               max_nesting_depth: max_nesting_depth)
    end

    def react_modal_for(file_type, single: true)
      @output_react_meta_data = true

      if ['new', 'edit', 'create', 'update'].include?(action_name)
        mode = single ? 'modal-single-select' : 'modal-multi-select'

        content_tag(:div,
                    nil,
                    'class': 'folio-react-wrap',
                    'data-file-type': file_type,
                    'data-mode': mode)
      end
    end

    def console_form_atoms(f)
      @output_react_meta_data = true

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
        placementType: f.object.class.to_s,
        className: f.object.class.to_s,
      }

      content_tag(:div, nil, 'class': 'f-c-atoms folio-react-wrap',
                             'data-mode': 'atoms',
                             'data-atoms': data.to_json)
    end

    def react_meta_data
      {
        tags: react_meta_data_tags,
      }.to_json
    end

    def react_meta_data_tags
      key = [
        'folio/console/react_meta_data_tags',
        Folio::File.maximum(:updated_at),
      ]

      Rails.cache.fetch(key, expires_in: 1.day) do
        Folio::File.tag_counts.order(:name).pluck(:name)
      end
    end

    private
      def react_files(file_type, selected_placements, attachmentable:, type:, atom_setting: nil)
        @output_react_meta_data = true

        if selected_placements.present?
          placements = selected_placements.ordered.map do |fp|
            {
              id: fp.id,
              file_id: fp.file.id,
              alt: fp.alt,
              title: fp.title,
              file: Folio::Console::FileSerializer.new(fp.file)
                                                  .serializable_hash[:data]
            }
          end.to_json
        else
          placements = nil
        end

        class_name = 'folio-react-wrap'

        if atom_setting
          class_name = "#{class_name} f-c-js-atoms-placement-setting"
        end

        content_tag(:div, nil,
          'class': class_name,
          'data-original-placements': placements,
          'data-file-type': file_type,
          'data-mode': 'multi-select',
          'data-attachmentable': attachmentable,
          'data-placement-type': type,
          'data-atom-setting': atom_setting,
        )
      end
  end
end
