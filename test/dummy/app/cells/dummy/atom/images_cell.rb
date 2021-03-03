# frozen_string_literal: true

class Dummy::Atom::ImagesCell < ApplicationCell
  DYNAMIC_TARGET_HEIGHT = 250
  DYNAMIC_THUMB_HEIGHT = 500

  def show
    render if model && model.image_placements.present?
  end

  def col_number
    @col_number ||= case model.image_placements.size
                    when 1
                      6
                    when 2
                      6
                    else
                      4
    end
  end

  def grid_width
    @grid_width ||= case model.image_placements.size
                    when 1
                      540
                    when 2
                      540
                    else
                      350
    end
  end

  def dynamic_style(placement)
    file = placement.file
    width = DYNAMIC_TARGET_HEIGHT * file.file_width / file.file_height
    max_width = DYNAMIC_THUMB_HEIGHT * file.file_width / file.file.height

    "width: #{width}px; flex-grow: #{width}; max-width: #{max_width}px"
  end

  def dynamic_max_width(placement)
    nil
  end
end
