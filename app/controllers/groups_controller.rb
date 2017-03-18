class GroupsController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  def show
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.json { render :show, status: :created }
      else
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

private

  def group_params
    params.require(:group).permit(:slug, :name, :parent_group_slug, :group_type, content_item_ids: [])
  end
end
