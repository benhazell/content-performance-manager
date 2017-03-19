require "rails_helper"

RSpec.describe GroupsController, type: :routing do
  describe "routing" do
    it "routes to #show" do
      expect(get: "/groups/1").to route_to("groups#show", id: "1")
    end
    it "routes to #index" do
      expect(get: "/groups").to route_to("groups#index")
    end
    it "routes to #destroy" do
      expect(delete: "/groups/1").to route_to("groups#destroy", id: "1")
    end
  end
end
