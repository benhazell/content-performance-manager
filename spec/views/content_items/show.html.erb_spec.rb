require 'rails_helper'

RSpec.describe 'content_items/show.html.erb', type: :view do
  let(:content_item) { build(:content_item).decorate }

  before do
    assign(:content_item, content_item)
    # content_item.proxy = {}
  end

  it 'renders the table header with the right headings' do
    render

    expect(rendered).to have_selector('table th:first-child', text: 'Content item attribute')
    expect(rendered).to have_selector('table th:nth(2)', text: 'Value')
  end

  it 'renders the title' do
    allow(content_item).to receive(:title).and_return("A Title")
    render

    expect(rendered).to have_selector('h1', text: 'A Title')
  end

  it 'renders the url' do
    allow(content_item).to receive(:url).and_return("https://gov.uk/content/1/path")
    allow(content_item).to receive(:title).and_return("A Title")

    render

    expect(rendered).to have_selector('td', text: 'Page on GOV.UK')
    expect(rendered).to have_selector('td + td a[href="https://gov.uk/content/1/path"]', text: 'A Title')
  end

  it 'renders the document type' do
    allow(content_item).to receive(:document_type).and_return("guidance")

    render

    expect(rendered).to have_selector('td', text: 'Type of document')
    expect(rendered).to have_selector('td + td', 'text': 'guidance')
  end

  it 'renders the number of views' do
    allow(content_item).to receive(:unique_page_views).and_return(10)

    render

    expect(rendered).to have_selector('td', text: 'Unique page views (last 1 month)')
    expect(rendered).to have_selector('td + td', 'text': 10)
  end

  it 'renders the last updated date' do
    allow(content_item).to receive(:last_updated).and_return("2 months ago")

    render

    expect(rendered).to have_selector('td', text: 'Last updated')
    expect(rendered).to have_selector('td + td', text: '2 months ago')
  end

  it 'renders the description of the content item' do
    allow(content_item).to receive(:description).and_return("The description of a content item")

    render

    expect(rendered).to have_selector('td', text: 'Description')
    expect(rendered).to have_selector('td + td', text: 'The description of a content item')
  end

  it 'renders the number of pdfs the content item has' do
    allow(content_item).to receive(:number_of_pdfs).and_return(10)

    render

    expect(rendered).to have_selector('td', text: 'Number of pdfs')
    expect(rendered).to have_selector('td + td', text: 10)
  end

  it 'renders the taxonomies' do
    content_item.taxonomies << build_list(:taxonomy, 2, title: "Taxon Title")

    render

    expect(rendered).to have_selector('td', text: 'Taxonomies')
    expect(rendered).to have_selector('td + td', text: "Taxon Title, Taxon Title")
  end

  it 'renders the organisations' do
    organisations = build_list(:organisation, 2, title: "Org Title")
    content_item.organisations << organisations

    render

    expect(rendered).to have_selector('td', text: 'Organisation')
    expect(rendered).to have_selector('td + td', text: 'Org Title, Org Title')
  end
end
