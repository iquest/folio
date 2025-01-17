# frozen_string_literal: true

class Dummy::Ui::DisclaimerCell < ApplicationCell
  def page
  end

  def text
    if page
      link = link_to(t(".link"), url_for(page))
    else
      link = t(".link")
    end

    t(".text", link: link)
  end
end
