require "rails_helper"

RSpec.describe ContentItem, type: :model do
  it { should have_and_belong_to_many(:organisations) }

  it { should have_and_belong_to_many(:taxonomies) }

  describe "#create_or_update" do
    it "creates a content item if it does not exist" do
      content_item = { content_id: "second_id", taxons: [], organisations: [] }

      expect { ContentItem.create_or_update!(content_item) }.to change { ContentItem.count }.by(1)
    end

    it "updates a content item if it already exists" do
      create(:content_item, content_id: "the_id", title: "the title")

      content_item = { content_id: "the_id", title: "a new title", taxons: [], organisations: [] }

      expect { ContentItem.create_or_update!(content_item) }.to change { ContentItem.count }.by(0)
      expect(ContentItem.find_by(content_id: "the_id").title).to eq("a new title")
    end

    it "creates a content item when the content item has attributes that don't exist on the model" do
      content_item = { content_id: "the_id", extra_attr: "extra", taxons: [], organisations: [] }

      expect { ContentItem.create_or_update!(content_item) }.to change { ContentItem.count }.by(1)
    end

    it "adds the organisation to the content item" do
      content_item = { content_id: "the_id", taxons: [], organisations: [{ title: "the organisation" }] }
      organisation = create(:organisation, title: "the organisation")

      ContentItem.create_or_update!(content_item)
      organisations = ContentItem.find_by(content_id: "the_id").organisations

      expect(organisations).to eq([organisation])
    end

    it "adds the taxonomies to the content item" do
      create(:taxonomy, content_id: "taxon_1")
      create(:taxonomy, content_id: "taxon_2")
      taxons = [{ content_id: "taxon_1" }, { content_id: "taxon_2" }]
      content_item = { content_id: "the_id", taxons: taxons, organisations: [] }

      ContentItem.create_or_update!(content_item)

      taxonomies = ContentItem.find_by(content_id: "the_id").taxonomies
      expect(taxonomies.count).to eq(2)
    end
  end

  describe "#add_organisations_by_title" do
    it "adds organisations to the content item" do
      create(:organisation, title: "org 1")
      create(:organisation, title: "org 2")
      organisations = [{ title: "org 1" }, { title: "org 2" }]
      content_item = create(:content_item)

      content_item.add_organisations_by_title(organisations)

      expect(content_item.organisations.count).to eq(2)
    end

    it "does not add an organisation that is already associated with the content item" do
      organisation = create(:organisation, title: "org 1")
      content_item = create(:content_item)
      content_item.organisations << organisation

      content_item.add_organisations_by_title([{ title: "org 1" }])

      expect(content_item.organisations.count).to eq(1)
    end
  end

  describe "#add_taxonomies_by_id" do
    it "adds taxonomies to the content item by taxon content_id" do
      content_item = create(:content_item)
      taxons = [{ content_id: "taxon_1" }, { content_id: "taxon_2" }]
      create(:taxonomy, content_id: "taxon_1")
      create(:taxonomy, content_id: "taxon_2")

      content_item.add_taxonomies_by_id(taxons)

      expect(content_item.taxonomies.count).to eq(2)
    end

    it "does not add taxonomies already associated with the content item" do
      content_item = create(:content_item)
      taxon = create(:taxonomy, content_id: "taxon_1")
      content_item.taxonomies << taxon

      content_item.add_taxonomies_by_id([{ content_id: "taxon_1" }])

      expect(content_item.taxonomies.count).to eq(1)
    end
  end
end
