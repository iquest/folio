# frozen_string_literal: true

class CreateFriendlyIdSlugs < ActiveRecord::Migration[5.1]
  def up
    unless table_exists?(:friendly_id_slugs)
      create_table :friendly_id_slugs do |t|
        t.string   :slug,           null: false
        t.integer  :sluggable_id,   null: false
        t.string   :sluggable_type, limit: 50
        t.string   :scope
        t.datetime :created_at
      end
      add_index :friendly_id_slugs, :sluggable_id
      add_index :friendly_id_slugs, %i[slug sluggable_type]
      add_index :friendly_id_slugs, %i[slug sluggable_type scope], unique: true
      add_index :friendly_id_slugs, :sluggable_type
    end
  end

  def down
    drop_table :friendly_id_slugs
  end
end
