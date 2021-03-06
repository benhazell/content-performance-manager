RSpec.describe GoogleAnalytics::Responses::PageViewsResponse do
  let(:two_page_views_response) do
    GoogleAnalyticsFactory.build_page_views_response([
      {
        base_path: "/check-uk-visa",
        one_month_page_views: 400,
        six_months_page_views: 4800,
      },
      {
        base_path: "/marriage-abroad",
        one_month_page_views: 500,
        six_months_page_views: 6000,
      }
    ])
  end

  it "returns the number of page views for content items" do
    page_views = described_class.new.parse(two_page_views_response)
    expected_response = [
      {
        base_path: "/check-uk-visa",
        one_month_page_views: 400,
        six_months_page_views: 4800,
      },
      {
        base_path: "/marriage-abroad",
        one_month_page_views: 500,
        six_months_page_views: 6000,
      }
    ]

    expect(page_views).to eq(expected_response)
  end
end
