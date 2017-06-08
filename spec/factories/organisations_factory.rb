FactoryGirl.define do
  factory :organisation do
    sequence(:id) { |index| index }
    sequence(:slug) { |index| "slug-#{index}" }
    sequence(:title) { |index| "organisation-title-#{index}" }
    sequence(:content_id) { |index| "organisation-content-id-#{index}" }
  end
end
