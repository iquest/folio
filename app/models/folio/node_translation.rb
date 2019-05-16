# frozen_string_literal: true

class Folio::NodeTranslation < Folio::Node
  # Relations
  belongs_to :node_original, class_name: 'Folio::Node', foreign_key: :original_id

  # Validations
  validates :locale, uniqueness: { scope: [:original_id] }
  validates :node_original, presence: true

  # Scopes
  delegate :parent, to: :node_original
  delegate :original, to: :node_original
  delegate :translations, to: :node_original

  def translate(locale = I18n.locale)
    if locale == self.locale.to_sym
      cast
    elsif node_original.node_translations.where(locale: locale).exists?
      self.node_translations.find_by(locale: locale).cast
    else
      nil
    end
  end

  def console_selectable?
    false
  end
end

# == Schema Information
#
# Table name: folio_nodes
#
#  id               :bigint(8)        not null, primary key
#  title            :string
#  slug             :string
#  perex            :text
#  content          :text
#  meta_title       :string(512)
#  meta_description :text
#  code             :string
#  ancestry         :string
#  type             :string
#  featured         :boolean
#  position         :integer
#  published        :boolean
#  published_at     :datetime
#  original_id      :integer
#  locale           :string(6)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_folio_nodes_on_ancestry      (ancestry)
#  index_folio_nodes_on_code          (code)
#  index_folio_nodes_on_featured      (featured)
#  index_folio_nodes_on_locale        (locale)
#  index_folio_nodes_on_original_id   (original_id)
#  index_folio_nodes_on_position      (position)
#  index_folio_nodes_on_published     (published)
#  index_folio_nodes_on_published_at  (published_at)
#  index_folio_nodes_on_slug          (slug)
#  index_folio_nodes_on_type          (type)
#
