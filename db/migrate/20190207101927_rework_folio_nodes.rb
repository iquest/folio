# frozen_string_literal: true

class ReworkFolioNodes < ActiveRecord::Migration[5.2]
  def change
    # rename table
    rename_table :folio_nodes, :folio_pages

    # fix types
    conn = ActiveRecord::Base.connection
    conn.execute <<~SQL
      UPDATE folio_pages
      SET
        type = 'Folio::Page'
      WHERE
        type IN ('Folio::Node', 'Folio::Category', 'Folio::NodeTranslation')
    SQL

    [
      ['folio_atoms', 'placement_type'],
      ['folio_atoms', 'model_type'],
      ['folio_file_placements', 'placement_type'],
      ['folio_menu_items', 'target_type'],
      ['friendly_id_slugs', 'sluggable_type'],
      ['pg_search_documents', 'searchable_type'],
      ['taggings', 'taggable_type'],
    ].each do |table, col|
      conn.execute <<~SQL
        UPDATE #{table}
        SET
          #{col} = 'Folio::Page'
        WHERE
          #{col} IN ('Folio::Node', 'Folio::Category', 'Folio::NodeTranslation')
      SQL
    end

    # correct Folio::NodeTranslation type
    Folio::Page.where.not(original_id: nil).find_each do |page|
      page.update_column(:type, page.original.type)
    end

    # convert content to Text atoms
    columns = Folio::Page.column_names.grep(/content.*/)

    puts 'Converting node contents to atoms'

    Folio::Page.find_each do |node|
      if node.content.present?
        values = {}

        columns.each do |col|
          if node.send(col).present?
            values[col] = node.send(col)
          end
        end

        if values.blank?
          print '-'
          next
        end

        if Folio::Atom::Text.create(values.merge(placement: node, position: -1))
          print '.'
        else
          print 'x'
        end
      end
    end

    remove_column :folio_pages, :content
    remove_column :folio_pages, :code
  end
end