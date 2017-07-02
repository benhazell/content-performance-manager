RSpec.describe ContentItem, type: :model do
  describe "callbacks" do
    subject { FactoryGirl.build(:content_item) }

    it "precomputes the content_item's report row after saving" do
      expect { subject.save! }.to change(ReportRow, :count).by(1)
      expect { subject.save! }.not_to change(ReportRow, :count)
    end
  end

  describe ".next_item" do
    let!(:content_items) { FactoryGirl.create_list(:content_item, 5) }

    it "returns the next item given the current item" do
      result = ContentItem.all.next_item(content_items[0])
      expect(result).to eq(content_items[1])

      result = ContentItem.all.next_item(content_items[1])
      expect(result).to eq(content_items[2])

      result = ContentItem.all.next_item(content_items[2])
      expect(result).to eq(content_items[3])

      result = ContentItem.all.next_item(content_items[3])
      expect(result).to eq(content_items[4])
    end

    it "returns nil if there's no next item" do
      result = ContentItem.all.next_item(content_items[4])
      expect(result).to be_nil
    end

    it "returns nil if the current item isn't in the scope" do
      result = ContentItem.offset(1).next_item(ContentItem.first)
      expect(result).to be_nil
    end

    it "is based on the filtered, ordered scope" do
      scope = ContentItem.limit(3).offset(1).order("id desc")

      result = scope.next_item(content_items[3])
      expect(result).to eq(content_items[2])

      result = scope.next_item(content_items[2])
      expect(result).to eq(content_items[1])

      result = scope.next_item(content_items[1])
      expect(result).to be_nil
    end
  end

  describe ".targets_of" do
    let!(:a) { FactoryGirl.create(:content_item) }
    let!(:b) { FactoryGirl.create(:content_item) }
    let!(:c) { FactoryGirl.create(:content_item) }

    before do
      FactoryGirl.create(:link, source: a, target: b, link_type: "type1")
      FactoryGirl.create(:link, source: b, target: a, link_type: "type1")

      FactoryGirl.create(:link, source: a, target: c, link_type: "type2")
      FactoryGirl.create(:link, source: b, target: c, link_type: "type2")
    end

    it "returns a scope of items that have links to them with the given type" do
      results = described_class.targets_of(link_type: "type1")
      expect(results).to match_array [a, b]

      results = described_class.targets_of(link_type: "type2")
      expect(results).to eq [c]

      results = described_class.targets_of(link_type: "type3")
      expect(results).to eq []
    end

    it "selects a count of the number of incoming links" do
      results = described_class.targets_of(link_type: "type1")
      expect(results.map(&:incoming_links_count)).to eq [1, 1]

      results = described_class.targets_of(link_type: "type2")
      expect(results.map(&:incoming_links_count)).to eq [2]
    end

    it "can count incoming links for a subset of content items" do
      subset = described_class.where(id: [a])

      results = described_class.targets_of(link_type: "type1", scope_to_count: subset)
      expect(results.map(&:incoming_links_count)).to eq [1]

      results = described_class.targets_of(link_type: "type2", scope_to_count: subset)
      expect(results.map(&:incoming_links_count)).to eq [1]
    end

    it "can cope with empty content item scopes" do
      subset = described_class.none
      results = described_class.targets_of(link_type: "anything", scope_to_count: subset)

      expect { results.first }.not_to raise_error
    end
  end

  describe ".document_type_counts" do
    before do
      FactoryGirl.create_list(:content_item, 2, document_type: "organisation")
      FactoryGirl.create_list(:content_item, 3, document_type: "policy")
    end

    it "returns a hash of document_types to the count of items" do
      result = described_class.document_type_counts
      expect(result).to eq("organisation" => 2, "policy" => 3)
    end

    it "can be chained on scopes" do
      scope = described_class.where(document_type: "organisation")

      result = scope.document_type_counts
      expect(result).to eq("organisation" => 2)
    end

    it "orders alphabetically" do
      FactoryGirl.create_list(:content_item, 4, document_type: "guide")

      result = described_class.document_type_counts
      expect(result.to_a).to eq [
        ["guide", 4],
        ["organisation", 2],
        ["policy", 3],
      ]
    end
  end

  describe "#title_with_count" do
    before do
      item = FactoryGirl.create(:content_item, title: "Title")
      FactoryGirl.create(:link, source: item, target: item, link_type: "type")
    end

    it "returns the title with the count of incoming links" do
      item = described_class.targets_of(link_type: "type").first
      expect(item.title_with_count).to eq("Title (1)")
    end

    it "returns the title if incoming_links_count isn't set" do
      item = described_class.first
      expect(item.title_with_count).to eq("Title")
    end
  end

  describe "#url" do
    it "returns a url to a content item on gov.uk" do
      content_item = build(:content_item, base_path: "/api/content/item/path/1")
      expect(content_item.url).to eq("https://gov.uk/api/content/item/path/1")
    end
  end

  describe "#add_taxons_by_id" do
    it "adds taxons to the content item by taxon content_id" do
      content_item = create(:content_item)
      taxons = %w(taxon_1 taxon_2)
      create(:taxon, content_id: "taxon_1")
      create(:taxon, content_id: "taxon_2")

      content_item.add_taxons_by_id(taxons)

      expect(content_item.taxons.count).to eq(2)
    end

    it "does not add taxons already associated with the content item" do
      content_item = create(:content_item)
      taxon = create(:taxon, content_id: "taxon_1")
      content_item.taxons << taxon

      content_item.add_taxons_by_id(%w(taxon_1))

      expect(content_item.taxons.count).to eq(1)
    end
  end

  describe "#linked_topics" do
    it "returns the topics linked to the Content Item" do
      item =  FactoryGirl.create(:content_item)
      topic = FactoryGirl.create(:content_item)

      FactoryGirl.create(:link, source: item, target: topic, link_type: "topics")
      expect(item.linked_topics).to eq [topic]
    end
  end

  describe "#guidance?" do
    it "returns true if document type is `guidance`" do
      content_item = build(:content_item, document_type: "guidance")

      expect(content_item.guidance?).to be true
    end

    it "returns false otherwise" do
      content_item = build(:content_item, document_type: "non-guidance")

      expect(content_item.guidance?).to be false
    end
  end

  describe "withdrawn?" do
    it "returns false" do
      content_item = build(:content_item)

      expect(content_item.withdrawn?).to be false
    end
  end

  describe "#whitehall_url" do
    it "returns a URL to the whitehall edit page" do
      content_item = FactoryGirl.build(
        :content_item,
        publishing_app: "whitehall",
        content_id: "id123",
      )

      expect(content_item.whitehall_url).to eq(
        "#{WHITEHALL}/government/admin/by-content-id/id123"
      )
    end

    it "returns nil if the publishing_app isn't whitehall" do
      content_item = FactoryGirl.build(:content_item)
      expect(content_item.whitehall_url).to be_nil
    end
  end
end
