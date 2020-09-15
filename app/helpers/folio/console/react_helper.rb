# frozen_string_literal: true

module Folio::Console::ReactHelper
  def react_images(selected_placements = nil,
                   attachmentable: "page",
                   type: :image_placements,
                   atom_setting: nil)
    react_files("Folio::Image",
                selected_placements,
                attachmentable: attachmentable,
                type: type,
                atom_setting: atom_setting)
  end

  def react_documents(selected_placements = nil,
                      attachmentable: "page",
                      type: :document_placements,
                      atom_setting: nil)
    react_files("Folio::Document",
                selected_placements,
                attachmentable: attachmentable,
                type: type,
                atom_setting: atom_setting)
  end

  def react_picker(f, placement_key, file_type: "Folio::Image", title: nil, atom_setting: nil)
    raw cell("folio/console/react_picker", f, placement_key: placement_key,
                                              title: title,
                                              file_type: file_type,
                                              atom_setting: atom_setting)
  end

  def react_ancestry(klass, max_nesting_depth: 2)
    raw cell("folio/console/react_ancestry",
             klass,
             max_nesting_depth: max_nesting_depth)
  end

  def react_modal_for(file_type)
    if ["new", "edit", "create", "update"].include?(action_name)
      klass = file_type.constantize
      begin
        url = url_for([:console, :api, klass])
      rescue StandardError
        url = main_app.url_for([:console, :api, klass])
      end

      content_tag(:div,
                  nil,
                  'class': "folio-react-wrap",
                  'data-file-type': file_type,
                  'data-files-url': url,
                  'data-react-type': klass.react_type,
                  'data-mode': "modal-single-select")
    end
  end

  def console_form_atoms(f)
    if f.object.class.respond_to?(:atom_locales)
      atoms = {}
      destroyed_ids = {}
      f.object.class.atom_locales.each do |locale|
        key = "#{locale}_atoms"
        atoms[key] = []
        destroyed_ids[key] = []

        f.object.send(key).to_a.each do |atom|
          if atom.marked_for_destruction?
            destroyed_ids[key] << atom.id
          else
            atoms[key] << atom.to_h
          end
        end
      end
    else
      atoms = { atoms: [] }
      destroyed_ids = { atoms: [] }

      f.object.atoms.to_a.each do |atom|
        if atom.marked_for_destruction?
          destroyed_ids[:atoms] << atom.id
        else
          atoms[:atoms] << atom.to_h
        end
      end
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

    content_tag(:div, nil, 'class': "f-c-atoms folio-react-wrap",
                           'data-mode': "atoms",
                           'data-atoms': data.to_json)
  end

  def react_files(file_type, selected_placements, attachmentable:, type:, atom_setting: nil)
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

    class_name = "folio-react-wrap"

    if atom_setting
      class_name = "#{class_name} f-c-js-atoms-placement-setting"
    end

    klass = file_type.constantize

    begin
      url = url_for([:console, :api, klass])
    rescue StandardError
      url = main_app.url_for([:console, :api, klass])
    end

    content_tag(:div, nil,
      'class': class_name,
      'data-original-placements': placements,
      'data-file-type': file_type,
      'data-files-url': url,
      'data-react-type': klass.react_type,
      'data-mode': "multi-select",
      'data-attachmentable': attachmentable,
      'data-placement-type': type,
      'data-atom-setting': atom_setting,
    )
  end
end
