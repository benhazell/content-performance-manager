require 'rails_helper'
require 'features/pagination_spec_helper'

RSpec.feature "Search in content items", type: :feature do

  # before do
  #   stub_request(:get, %r{.*?/content/*}).to_return(status: 200, body:  {}.to_json)
  # end

  scenario "the user enters a text in the search box and retrieves a filtered list" do
    create :content_item, title: "some text"
    create :content_item, title: "another text"

    visit "/content_items"
    fill_in 'query', with: 'some text'

    click_on "Search"
    expect(page).to have_selector('main tbody tr', count: 1)
  end

  scenario "the user enters a text in the search box and retrieves a filtered list" do
    create :content_item, title: "title - a"
    create :content_item, title: "title - b"

    visit "/content_items?order=desc&sort=title"
    fill_in 'query', with: 'title -'

    click_on "Search"
    expect(page).to have_selector('main tbody tr:first', text: 'title - b')
  end

  scenario "show the query entered by the user after searching" do
    visit "/content_items"
    fill_in 'query', with: 'a search value'

    click_on "Search"
    expect(page).to have_field(:query, with: 'a search value')
  end
end
