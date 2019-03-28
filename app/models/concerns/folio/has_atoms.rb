# frozen_string_literal: true

module Folio::HasAtoms
  module Basic
    extend ActiveSupport::Concern

    included do
      has_many :atoms, -> { ordered },
                       class_name: 'Folio::Atom::Base',
                       as: :placement,
                       inverse_of: :placement,
                       dependent: :destroy

      accepts_nested_attributes_for :atoms,
                                    reject_if: :all_blank,
                                    allow_destroy: true
    end

    def atoms_in_molecules
      Folio::Atom.atoms_in_molecules(atoms)
    end

    def atoms_image_placements
      Folio::Atom.atoms_image_placements(atoms)
    end
  end

  module Localized
    extend ActiveSupport::Concern

    included do
      atom_locales.each do |locale|
        has_many "#{locale}_atoms".to_sym, -> { ordered.where(locale: locale) },
                                           class_name: 'Folio::Atom::Base',
                                           as: :placement,
                                           inverse_of: :placement,
                                           dependent: :destroy

        accepts_nested_attributes_for "#{locale}_atoms".to_sym,
                                      reject_if: :all_blank,
                                      allow_destroy: true
      end
    end

    class_methods do
      def atom_locales
        if Rails.application.config.folio_using_traco
          I18n.available_locales
        else
          [I18n.default_locale]
        end
      end
    end

    def atoms(locale = I18n.locale)
      send("#{locale}_atoms")
    end

    def atoms_in_molecules
      Folio::Atom.atoms_in_molecules(atoms)
    end
  end
end
