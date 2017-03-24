FactoryGirl.define do

    sequence(:content_item_title) { |index| "content-item-title-#{index}" }
    sequence(:content_item_description) { |index| "content-item-description-#{index}" }
    sequence(:content_item_document_type) { |index| "document_type-#{index}" }
    sequence(:content_item_base_path) { |index| "api/content/item/path-#{index}"}
    sequence(:content_item_public_updated_at) { Time.now }

  factory :content_item do
    sequence(:content_id) { |index| "content-id-#{index}" }
    sequence(:id) { |index| index }

    after(:build) do |ci, evaluator|
      user_attributes = OpenStruct.new(evaluator.instance_variable_get(:@overrides))

      stubbed_response = {
        title: user_attributes.title || generate(:content_item_title),
        description: user_attributes.description || generate(:content_item_description),
        base_path: user_attributes.base_path || generate(:content_item_base_path),
        document_type: user_attributes.document_type || generate(:content_item_document_type),
        public_updated_at: user_attributes.public_updated_at || generate(:content_item_public_updated_at),
      }

      WebMock.stub_request(:get, %r{.*?/content/#{ci.content_id}}).to_return(status: 200, body:  stubbed_response.to_json)
      # MockedContnetItemService.register(ci.id, ci.attributes)
    end

    factory :content_item_with_organisations do
      transient do
        organisations_count 1
      end
      after(:create) do |content_item, evaluator|
        create_list(:organisation, evaluator.organisations_count, content_items: [content_item])
      end
    end
  end
end
