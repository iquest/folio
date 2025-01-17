# frozen_string_literal: true

class Dummy::Ui::ShareCell < ApplicationCell
  class_name "d-ui-share", :mobile_collapsible

  def share_links
    [
      {
        icon: :facebook,
        title: t(".facebook"),
        url: facebook_url,
        target: "_blank",
      },
      {
        icon: :messenger,
        title: t(".messenger"),
        url: messenger_url,
        target: "_blank",
      },
      {
        icon: :twitter,
        title: t(".twitter"),
        url: twitter_url,
        target: "_blank",
      },
      {
        icon: :mail,
        title: t(".email"),
        url: mail_url,
      },
    ]
  end

  def url
    @url ||= model.presence || request.url
  end

  def facebook_url
    h = { u: url, src: "sdkpreparse" }
    "https://www.facebook.com/sharer/sharer.php?#{h.to_query}"
  end

  def messenger_url
    h = { u: url }
    "messenger://share/?#{h.to_query}"
  end

  def twitter_url
    h = { url: url }
    "https://twitter.com/share?#{h.to_query}"
  end

  def mail_url
    h = { body: url }
    "mailto:?#{h.to_query}"
  end
end
