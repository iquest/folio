# frozen_string_literal: true

require_dependency 'folio/application_controller'

module Folio
  class Console::NodesController < Console::BaseController
    include Console::NodesHelper

    respond_to :json, only: %i[update set_position]

    before_action :find_node, except: [:index, :create, :new, :set_position]
    before_action :find_files, only: [:new, :edit, :create, :update]

    def index
      if params[:by_parent].present? && %i[by_query by_published by_type by_tag].map { |by| params[by].blank? }.all?
        parent = Folio::Node.find(params[:by_parent])
        @nodes = parent.subtree.original.arrange(order: 'position desc, created_at desc')
        @filtered = true
      elsif %i[by_query by_published by_type by_tag by_parent].map { |by| params[by].present? }.any?
        @nodes = Folio::Node.
        original.
        ordered.
        filter(filter_params).
        page(current_page)
        @filtered = true
      else
        @limit = 5
        @nodes = Folio::Node.original.arrange(order: 'position desc, created_at desc')
      end
    end

    def new
      if params[:node].blank? || params[:node][:original_id].blank?
        if params[:parent].present?
          parent = Folio::Node.find(params[:parent])
          @node = Folio::Node.new(parent: parent, type: parent.class.allowed_child_type)
        else
          @node = Folio::Node.new
        end
      else
        original = Folio::Node.find(params[:node][:original_id])

        @node = original.translate!(params[:node][:locale])

        redirect_to edit_console_node_path(@node.id)
      end

      after_new
    end

    def create
      # set type first beacuse of @node.additional_params
      @node = Folio::Node.new(type: params[:node][:type])
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

    def set_position
      Folio::Node.update(set_position_params.keys, set_position_params.values)
      render json: { success: 'success', status_code: '200' }
    end

  private
    def after_new
    end

    def find_node
      @node = Folio::Node.friendly.find(params[:id])
    end

    def find_files
      @images = Folio::Image.all.page(1).per(11)
      @documents = Folio::Image.all.page(1).per(11)
    end

    def filter_params
      params.permit(:by_query, :by_published, :by_type, :by_tag, :by_parent)
    end

    def node_params
      p = params.require(:node)
                .permit(:title,
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
                                           :model_id,
                                           :content,
                                           :position,
                                           :_destroy,
                                           file_placements_attributes: [:id,
                                                                        :file_id,
                                                                        :_destroy],
                                           ])
      p.delete(:slug) unless p[:slug].present?
      p.delete(:password) unless p[:password].present?
      p
    end

    def set_position_params
      params.require(:node)
    end
  end
end
