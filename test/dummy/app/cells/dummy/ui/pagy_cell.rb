# frozen_string_literal: true

class Dummy::Ui::PagyCell < ApplicationCell
  include Pagy::Frontend

  def show
    render if model.present? && model.try(:pages) && model.pages > 1
  end

  def link
    @link ||= pagy_link_proc(model)
  end
end
