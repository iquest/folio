# frozen_string_literal: true

module Folio
  class Document < Folio::File
    paginates_per 16
  end
end

# == Schema Information
#
# Table name: folio_files
#
#  id              :integer          not null, primary key
#  file_uid        :string
#  file_name       :string
#  type            :string
#  thumbnail_sizes :text             default("--- {}\n")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  file_width      :integer
#  file_height     :integer
#  file_size       :integer
#  mime_type       :string(255)
#
# Indexes
#
#  index_folio_files_on_type  (type)
#