class ContentItemsController < ApplicationController
  before_action :set_organisation, only: :index
  before_action :set_taxon, only: :index
  before_action :set_filter_options, only: :index
  before_action :set_query_options, only: :index
  before_action :set_all_organisations, only: :index
  before_action :set_all_taxons, only: :index

  def index
    query = Queries::ContentItemsQuery.new(@query_options)
    @content_items = query.paginated_results.decorate
    @metrics = MetricBuilder.new.run_collection(query.results)
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
