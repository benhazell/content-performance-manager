require 'rails_helper'

RSpec.describe "API::Groups", type: :request do
  describe "GET /groups/{id}" do
    it "returns JSON with the group " do
      group = create :group, name: "a-name"
      get group_path(group), format: :json

      expect(JSON.parse(response.body)).to include("name" => "a-name")
    end
  end
end
