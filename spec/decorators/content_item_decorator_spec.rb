RSpec.describe ContentItemDecorator, type: :decorator do
  include Capybara::RSpecMatchers

  describe "#last_updated" do
    let(:content_item) { build(:content_item, public_updated_at: nil).decorate }

    it "displays Never when content item has not been updated" do
      expect(content_item.last_updated).to eq('Never')
    end
  end

  describe "#feedex_link" do
    let(:content_item) { build(:content_item, base_path: "/the-base-path").decorate }

    it "has a link to FeedEx" do
      expect(content_item.feedex_link).to have_link("View feedback on FeedEx", href: "#{Plek.find('support')}/anonymous_feedback?path=/the-base-path")
    end
  end

  describe "#organisation_links" do
    let(:content_item) { create(:content_item).decorate }

    it "has a comma between names" do
      hmrc = FactoryGirl.create(:content_item, title: "HMRC")
      FactoryGirl.create(:link, source_content_id: content_item.content_id, target_content_id: hmrc.content_id, link_type: "organisations")

      dfe = FactoryGirl.create(:content_item, title: "DFE")
      FactoryGirl.create(:link, source_content_id: content_item.content_id, target_content_id: dfe.content_id, link_type: "organisations")

      organisation_links = content_item.organisation_links

      expect(organisation_links).to include(%{<a href=\"/content_items/#{hmrc.id}">HMRC</a>})
      expect(organisation_links).to include(%{<a href=\"/content_items/#{dfe.id}">DFE</a>})
    end
  end

  describe "#list_taxons" do
    let(:taxons) { [build(:taxon, title: "taxon 1"), build(:taxon, title: "taxon 2")] }
    let(:content_item) { build(:content_item, taxons: taxons).decorate }

    it "returns a string of taxons separated by a comma" do
      taxons = content_item.taxons_as_string
      expect(taxons).to eq("taxon 1, taxon 2")
    end
  end
end
