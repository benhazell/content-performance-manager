require "rails_helper"

RSpec.describe ContentItemDecorator, type: :decorator do
  describe '#organisation_links' do
    let(:organisations) do
      [
        build(:organisation, slug: 'slug-1', title: 'title-1'),
        build(:organisation, slug: 'slug-2', title: 'title-2')
      ]
    end

    let(:content_item) { build(:content_item, organisations: organisations).decorate }

    it 'has a comma between names' do
      organisation_links = content_item.organisation_links

      expect(organisation_links).to include(%{<a href=\"/content_items?organisation_slug=slug-1\">title-1</a>})
      expect(organisation_links).to include(%{<a href=\"/content_items?organisation_slug=slug-2\">title-2</a>})
    end
  end

  describe "#list_taxons" do
    let(:taxonomies) { [build(:taxonomy, title: 'taxon 1'), build(:taxonomy, title: 'taxon 2')] }
    let(:content_item) { build(:content_item, taxonomies: taxonomies).decorate }

    it "returns a string of taxons separated by a comma" do
      taxons = content_item.taxons_as_string
      expect(taxons).to eq("taxon 1, taxon 2")
    end
  end

  describe "#title" do
    let(:content_item) { build(:content_item, title: "object title") }

    it "returns the context title if there is one" do
      decorated = content_item.decorate(context: { title: "context title" })
      expect(decorated.title).to eq("context title")
    end

    it "returns the object title when there is no context title" do
      decorated = content_item.decorate
      expect(decorated.title).to eq("object title")
    end
  end

  describe "#description" do
    let(:content_item) { build(:content_item, description: "object description") }

    it "returns the context description if there is one" do
      decorated = content_item.decorate(context: { description: "context description" })
      expect(decorated.description).to eq("context description")
    end

    it "returns the object description when there is no context description" do
      decorated = content_item.decorate
      expect(decorated.description).to eq("object description")
    end
  end

  describe "#document_type" do
    let(:content_item) { build(:content_item, document_type: "object document_type") }

    it "returns the context document_type if there is one" do
      decorated = content_item.decorate(context: { document_type: "context document_type" })
      expect(decorated.document_type).to eq("context document_type")
    end

    it "returns the object document_type when there is no context document_type" do
      decorated = content_item.decorate
      expect(decorated.document_type).to eq("object document_type")
    end
  end

  describe "#url" do
    let(:content_item) { build(:content_item, base_path: "/object/base_path") }

    it "returns the context base_path with the gov.uk prefix if there is one" do
      decorated = content_item.decorate(context: { base_path: "/context/base_path" })
      expect(decorated.url).to eq("https://gov.uk/context/base_path")
    end

    it "returns the object base_path with the gov.uk prefix when there is no context base_path" do
      decorated = content_item.decorate
      expect(decorated.url).to eq("https://gov.uk/object/base_path")
    end
  end
end
