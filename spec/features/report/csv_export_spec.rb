RSpec.feature "Exporting a CSV from the report page" do
  def content_type
    page.response_headers.fetch("Content-Type")
  end

  def content_disposition
    page.response_headers.fetch("Content-Disposition")
  end

  # before do
  #   example = FactoryGirl.create(
  #     :content_item,
  #     title: "Example",
  #     base_path: "/example",
  #   )
  #
  #   FactoryGirl.create(:audit, content_item: example)
  # end

  let!(:example) {
    FactoryGirl.create(
      :content_item,
      title: "Example",
      base_path: "/example",
    )
  }

  let!(:example2) {
    FactoryGirl.create(
      :content_item,
      title: "Example 2",
      base_path: "/example2",
    )
  }

  let!(:passing_audit) { FactoryGirl.create(:audit, content_item: example) }
  let!(:failing_audit) { FactoryGirl.create(:audit, content_item: example2) }

  before do
    bool = FactoryGirl.create(:boolean_question)
    free = FactoryGirl.create(:free_text_question)

    FactoryGirl.create(:response, audit: passing_audit, question: bool, value: "no")
    FactoryGirl.create(:response, audit: passing_audit, question: bool, value: "no")
    FactoryGirl.create(:response, audit: passing_audit, question: free, value: "Hello")

    FactoryGirl.create(:response, audit: failing_audit, question: bool, value: "no")
    FactoryGirl.create(:response, audit: failing_audit, question: bool, value: "yes")
    FactoryGirl.create(:response, audit: failing_audit, question: free, value: "Hello")
  end

  scenario "Exporting a csv file as an attachment" do
    visit audits_report_path
    click_link "Export filtered audit to CSV"

    expect(content_type).to eq("text/csv")
    expect(content_disposition).to start_with("attachment")
    expect(content_disposition).to include(
      'filename="Transformation_audit_report_CSV_download.csv"',
    )

    expect(page).to have_content("Title,URL")
    expect(page).to have_content("Example,https://gov.uk/example")

    expect(page).to have_content("No")
    expect(page).to have_content("Yes")
    # expect(passing_audit.failing?).to be_falsey
  end

  scenario "Applying the filters to the export" do
    visit audits_report_path

    select "Non Audited", from: "audit_status"
    click_on "Filter"

    click_link "Export filtered audit to CSV"
    expect(page).to have_no_content("Example,https://gov.uk/example")
  end
end
