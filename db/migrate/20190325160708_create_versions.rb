# frozen_string_literal: true

# This migration creates the `versions` table, the only schema PT requires.
# All other migrations PT provides are optional.
class CreateVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :versions do |t|
      t.string   :item_type, null: false
      t.integer  :item_id,   null: false
      t.string   :event,     null: false
      t.bigint   :whodunnit
      t.jsonb :object          # Full object changes
      t.jsonb :object_changes  # Optional column-level changes

      t.datetime :created_at
    end
    add_index :versions, %i(item_type item_id)
  end
end
