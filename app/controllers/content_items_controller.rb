class ContentItemsController < ApplicationController
  before_action :set_organisation, only: :index
  before_action :set_taxon, only: :index

  helper_method :filter_params

  def index
    @search = Search.new
    @search.filter_by(link_type: Search::FILTERABLE_LINK_TYPES, target_ids: params[:organisations]) if params[:organisations].present?
    @search.page = params[:page]
    @search.execute

    @content_items = @search.content_items.decorate

    @metrics = MetricBuilder.new.run_collection(ContentItem.all)
  end

  def show
    @content_item = ContentItem.find(params[:id]).decorate
  end

  private

  def set_query_options
    @query_options = {
      sort: params[:sort],
      order: params[:order],
      query: params[:query],
      page: params[:page],
      taxon: @taxon,
      organisation: @organisation
    }
  end

  def set_all_organisations
    @organisations = Organisation.order(:title)
  end

  def set_all_taxons
    @taxons = Taxon.order(:title)
  end

  def set_organisation
    @organisation = Organisation.find_by(content_id: params[:organisation_content_id]) if params[:organisation_content_id]
  end

  def set_taxon
    @taxon = Taxon.find_by(content_id: params[:taxon_content_id]) if params[:taxon_content_id]
  end

  def set_filter_options
    @filter_options = {}
    @filter_options[:organisation_content_id] = params[:organisation_content_id]
    @filter_options[:taxon_content_id] = params[:taxon_content_id]
    @filter_options[:query] = params[:query]
  end

end
