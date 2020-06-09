# frozen_string_literal: true

module Folio::Console::Api::FileControllerBase
  extend ActiveSupport::Concern

  def index
    pagy, records = pagy(folio_console_records.ordered, items: 100)
    meta = {
      page: pagy.page,
      pages: pagy.pages,
      from: pagy.from,
      to: pagy.to,
      count: pagy.count,
    }
    render_records(records, Folio::Console::FileSerializer, meta: meta)
  end

  def create
    file = @klass.create(file_params)
    render_record(file, Folio::Console::FileSerializer)
  end

  def update
    folio_console_record.update(file_params)
    render_record(folio_console_record, Folio::Console::FileSerializer)
  end

  def destroy
    folio_console_record.destroy!
    render json: { status: 200 }
  end

  def tag
    tag_params = params.permit(file_ids: [], tags: [])

    files = Folio::File.where(id: tag_params[:file_ids])

    Folio::File.transaction do
      files.each { |f| f.update!(tag_list: tag_params[:tags]) }
    end

    render_records(files, Folio::Console::FileSerializer)
  end

  def mass_destroy
    ids = params.require(:ids).split(',')
    @klass.where(id: ids).each(&:destroy!)
    render json: { data: { message: t('.success') }, status: 200 }
  rescue StandardError => e
    render json: { error: t('.failure', msg: e.message), status: 400 }
  end

  def change_file
    old_thumbnail_versions = folio_console_record.thumbnail_sizes

    if folio_console_record.update(file_params)
      if folio_console_record.is_a?(Folio::Image)
        old_thumbnail_versions.keys.each do |version|
          folio_console_record.thumb(version, immediate: true)
        end
      end
    end

    render_record(folio_console_record, Folio::Console::FileSerializer)
  end

  private
    def folio_console_collection_includes
      [:tags, :file_placements]
    end

    def filter_params
      params.permit(:by_file_name, :by_placement, :by_tags, :by_used)
    end

    def file_params
      p = params.require(:file)
                .require(:attributes)
                .permit(:tag_list,
                        :type,
                        :file,
                        tags: [])

      if p[:tags].present? && p[:tag_list].blank?
        p[:tag_list] = p.delete(:tags).join(',')
      end

      p
    end
end
