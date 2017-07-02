class ContentItemsController < ApplicationController
  helper_method :filter_params

  def index
    @search = Search.new
    @search.filter_by(link_type: Search::FILTERABLE_LINK_TYPES, target_ids: params[:organisations]) if params[:organisations].present?
    @search.page = params[:page]
    @search.execute

    @metrics = MetricBuilder.new.run_collection(@search.content_items)

    @content_items = @search.content_items.decorate
  end

  def show
    @content_item = ContentItem.find(params[:id]).decorate
  end
end
