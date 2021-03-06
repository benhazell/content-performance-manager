class GroupsController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  before_action :ensure_valid_token
  before_action :set_parent_group, only: :create
  before_action :set_group, only: %w(show destroy)

  def index
    @groups = if params[:group_type]
                Group.where(group_type: params[:group_type])
              else
                Group.all
              end
  end

  def show
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      render :show, status: :created
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    head :ok
  end

private

  def set_parent_group
    parent_group_slug = params[:group][:parent_group_slug]
    if parent_group_slug
      parent = Group.find_by(slug: parent_group_slug)
      params[:group][:parent_group_id] = parent.id
    end
  end

  def set_group
    @group = Group.find_by(slug: params[:slug])
  end

  def group_params
    params.require(:group).permit(:slug, :name, :parent_group_id, :group_type, content_item_ids: [])
  end

  def ensure_valid_token
    expected_token = ENV['CONTENT-PERFORMANCE-MANAGER-TOKEN']

    head 401 unless expected_token.present? && expected_token == params[:api_token]
  end
end
