# frozen_string_literal: true

require_dependency 'folio/application_controller'

module Folio
  class Console::NodesController < Console::BaseController
    include Console::NodesHelper

    before_action :find_node, except: [:index, :create, :new]
    before_action :find_files, only: [:new, :edit]

    def index
      if %i[by_query by_published by_type by_tag by_parent].map { |by| params[by].present? }.any?
        @nodes = Folio::Node.
        original.
        ordered.
        filter(filter_params).
        page(current_page)
      else
        @limit = 5
        @nodes = Folio::Node.original.arrange(order: 'position desc, created_at desc')
      end
    end

    def new
      if params[:node].blank? || params[:node][:original_id].blank?
        @node = Folio::Node.new()
      else
        original = Folio::Node.find(params[:node][:original_id])

        @node = original.translate!(params[:node][:locale])

        redirect_to edit_console_node_path(@node.id)
      end
    end

    def create
      # set type first beacuse of @node.additional_params
      @node = Folio::Node.new(type: params[:type])
      @node.update(node_params)
      respond_with @node, location: console_nodes_path
    end

    def update
      @node.update(node_params)
      respond_with @node, location: console_nodes_path
    end

    def destroy
      @node.destroy
      respond_with @node, location: console_nodes_path
    end

  private
    def find_node
      @node = Folio::Node.friendly.find(params[:id])
    end

    def find_files
      @images = Folio::Image.page(1)
      @documents = Folio::Document.page(1)
    end

    def filter_params
      params.permit(:by_query, :by_published, :by_type, :by_tag, :by_parent)
    end

    def node_params
      p = params.require(:node).permit(:title,
                                       :slug,
                                       :perex,
                                       :content,
                                       :meta_title,
                                       :meta_description,
                                       :code,
                                       :tag_list,
                                       :type,
                                       :featured,
                                       :published,
                                       :published_at,
                                       :locale,
                                       :parent_id,
                                       :original_id,
                                       *@node.additional_params,
                                       file_placements_attributes: [:id,
                                                                    :caption,
                                                                    :file_id,
                                                                    :_destroy],
                                       atoms_attributes: [:id,
                                                          :type,
                                                          :content,
                                                          :position,
                                                          :_destroy])
      p.delete(:password) unless p[:password].present?
      p
    end
  end
end
