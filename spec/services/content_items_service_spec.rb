require 'rails_helper'

RSpec.describe ContentItemsService do
  describe '#find_each' do
    it 'queries the publishing API for all content items of a given type' do
      subject.publishing_api = double
      expected_field_params = %i(content_id description title public_updated_at document_type base_path details)
      expected_query_params = { document_type: 'a_document_type', expand_links: true }

      expect(subject.publishing_api).to receive(:find_each).with(expected_field_params, expected_query_params)

      subject.find_each('a_document_type') {}
    end

    it 'yields the response with taxons and organisations' do
      results = []
      subject.publishing_api = double
      response = { expanded_links: {
          taxons: [:a],
          organisations: [:b]
        }
      }

      allow(subject.publishing_api).to receive(:find_each).and_yield(response)

      subject.find_each('a_document_type') { |value| results << value }

      expect(results.first).to include(taxons: [:a], organisations: [:b])
    end

    it 'raises an exception if no block is passed' do
      expect { subject.find_each('organisation-slug') }.to raise_exception('missing block!')
    end
  end

  describe "#get" do
    it 'queries the publishing API for a content item for a given ID and returns it' do
      subject.publishing_api = double

      expect(subject.publishing_api).to receive(:find_by_id).with("the_id").and_return({})

      content_item = subject.get("the_id")

      expect(content_item).to eq({})
    end
  end
end
