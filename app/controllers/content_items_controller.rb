class ContentItemsController < ApplicationController
  helper_method :filter_params, :primary_org_only?, :org_link_type

  def index
    @search = Search.new
    filter_by_organisation!(@search)
    @search.page = params[:page]
    @search.execute

    @metrics = MetricBuilder.new.run_collection(@search.unpaginated)

    @content_items = @search.content_items.decorate
  end

  def show
    @content_item = ContentItem.find(params[:id]).decorate
  end

  private

  def filter_by_organisation!(search)
    content_id = params[:organisations]
    search.filter_by(link_type: org_link_type, target_ids: content_id) if content_id.present?
  end

  def org_link_type
    primary_org_only? ? Link::PRIMARY_ORG : Link::ALL_ORGS
  end

  def primary_org_only?
    params[:primary].blank? || params[:primary] == "true"
  end
end
