# frozen_string_literal: true

module Atom
  class SingleImage < Folio::Atom::Base
    STRUCTURE = {
      cover: true,
    }

    validates :cover_placement,
              presence: true
  end
end