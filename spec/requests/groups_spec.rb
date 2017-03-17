require 'rails_helper'

RSpec.describe "API::Groups", type: :request do
  describe "GET /groups/{id}" do
    it "returns JSON with the group " do
      group = create :group, name: "a-name"
      get group_path(group), format: :json

      expect(JSON.parse(response.body)).to include("name" => "a-name")
    end
  end

  describe "POST /groups" do
    context "with valid params" do
      let(:valid_params) { { group: { name: "a-name", slug: "the-slug", group_type: "the-group-type" } } }

      it "creates the group" do
        expect {
          post groups_path params: valid_params, format: :json
        }.to change(Group, :count).by(1)
      end

      it "returns status `:created` status code" do
        post groups_path params: valid_params, format: :json

        expect(response).to have_http_status(201)
      end

      it "returns a JSON with the group details" do
        post groups_path params: valid_params, format: :json

        expect(JSON.parse(response.body)).to include("name" => "a-name")
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { group: { name: "a-name" } } }

      it "returns a `:unprocessable_entity` status code" do
        post groups_path params: invalid_params, format: :json

        expect(response).to have_http_status(422)
      end

      it "returns JSON including the errror details" do
        post groups_path params: invalid_params, format: :json

        expect(JSON.parse(response.body)).to include("group_type" => ["can't be blank"])
      end
    end
  end
end
