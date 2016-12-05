FactoryGirl.define do
  factory :content_item do
    sequence(:content_id) { |index| "7776ddf3-f918-5f32-bf18-dc1ced2eeeb#{index}" }
    link "api/content/item/path"
  end
end