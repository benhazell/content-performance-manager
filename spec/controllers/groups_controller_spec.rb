require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  describe "GET #index" do
    it "assigns all users as @users" do
      group = create(:group)
      get :index, format: :json

      expect(assigns(:groups)).to eq([group])
    end

    it "filters by group type" do
      create(:group)
      group2 = create(:group, group_type: 'the-type')
      get :index, params: { group_type: 'the-type' }, format: :json

      expect(assigns(:groups)).to eq([group2])
    end
  end

  describe "GET #show" do
    it "assigns the requested user as @user" do
      group = create :group
      get :show, format: :json, params: { id: group.to_param }

      expect(assigns(:group)).to eq(group)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { attributes_for(:group) }
    let(:invalid_attributes) { { name: 'a-name', group_type: 'a-type' } }

    context "with valid params" do
      it "creates a new Group" do
        expect {
          post :create, format: :json, params: { group: valid_attributes }
        }.to change(Group, :count).by(1)
      end

      it "assigns a newly created group as @group" do
        post :create, format: :json, params: { group: valid_attributes }
        expect(assigns(:group)).to be_a(Group)
        expect(assigns(:group)).to be_persisted
      end

      it "redirects to the created group" do
        post :create, format: :json, params: { group: valid_attributes }
        expect(response.status).to eq(201)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved group as @group" do
        post :create, format: :json, params: { group: invalid_attributes }

        expect(assigns(:group)).to be_a_new(Group)
        expect(assigns(:group).errors).to_not be_empty
      end
    end
  end
end
