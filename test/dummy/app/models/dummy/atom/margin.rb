# frozen_string_literal: true

class Dummy::Atom::Margin < Folio::Atom::Base
  ATTACHMENTS = %i[]

  STRUCTURE = {}

  ASSOCIATIONS = {}

  def self.cell_name
    "dummy/atom/margin"
  end

  def self.console_icon
    :space_bar
  end
end

# == Schema Information
#
# Table name: folio_atoms
#
#  id              :bigint(8)        not null, primary key
#  type            :string
#  position        :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  placement_type  :string
#  placement_id    :bigint(8)
#  locale          :string
#  data            :jsonb
#  associations    :jsonb
#  data_for_search :text
#
# Indexes
#
#  index_folio_atoms_on_placement_type_and_placement_id  (placement_type,placement_id)
#
