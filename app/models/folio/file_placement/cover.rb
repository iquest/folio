# frozen_string_literal: true

module Folio
  class FilePlacement::Cover < FilePlacement::Base
    include PregenerateThumbnails

    belongs_to :file, class_name: 'Folio::Image',
                      inverse_of: :file_placements,
                      required: true

    belongs_to :placement, polymorphic: true,
                           inverse_of: :cover_placement,
                           required: true,
                           touch: true
  end
end

# == Schema Information
#
# Table name: folio_file_placements
#
#  id             :bigint(8)        not null, primary key
#  placement_type :string
#  placement_id   :bigint(8)
#  file_id        :bigint(8)
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  type           :string
#  title          :text
#  alt            :string
#
# Indexes
#
#  index_folio_file_placements_on_file_id                          (file_id)
#  index_folio_file_placements_on_placement_type_and_placement_id  (placement_type,placement_id)
#  index_folio_file_placements_on_type                             (type)
#