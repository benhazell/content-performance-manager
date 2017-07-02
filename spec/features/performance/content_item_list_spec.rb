RSpec.feature "Content Items List", type: :feature do
  before do
    FactoryGirl.create(:user)
  end

  scenario "User does can see CPM feedback survey link in banner" do
    visit "/content_items"

    expect(page).to have_link("these quick questions")
  end

  scenario "Renders the page title" do
    visit "/content_items"

    expect(page).to have_selector('h1', text: 'GOV.UK')
  end

  scenario "Renders the table header" do
    visit "/content_items"

    expect(page).to have_selector('thead', text: 'Title')
    expect(page).to have_selector('thead tr:first-child th', text: 'Doc type')
    expect(page).to have_selector('thead tr:first-child th', text: 'Page views (1mth)')
    expect(page).to have_selector('thead tr:first-child th', text: 'Last major update')
  end

  scenario "Renders content item details" do
    create(:content_item,
      title: "a-title",
      document_type: "guide",
      one_month_page_views: "99",
      public_updated_at: 2.months.ago)

    visit "/content_items"

    expect(page).to have_text("a-title")
    expect(page).to have_text("Guide")
    expect(page).to have_text("99")
    expect(page).to have_text("2 months ago")
  end

  scenario "Renders all content items" do
    create_list :content_item, 2

    visit "/content_items"

    expect(page).to have_selector('table tbody tr', count: 2)
  end
end
