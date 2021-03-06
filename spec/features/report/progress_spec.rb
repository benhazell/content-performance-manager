RSpec.feature "Reporting on audit progress" do
  # Organisations:
  let!(:hmrc) { FactoryGirl.create(:content_item, title: "HMRC", document_type: "organisation") }

  # Policies:
  let!(:flying) { FactoryGirl.create(:content_item, title: "Flying abroad", document_type: "policy") }
  let!(:insurance) { FactoryGirl.create(:content_item, title: "Travel insurance", document_type: "policy") }

  before do
    flying_audit = FactoryGirl.create(:audit, content_item: flying)
    FactoryGirl.create(
      :response,
      question: FactoryGirl.create(:boolean_question),
      audit: flying_audit,
      value: "no"
    )

    insurance_audit = FactoryGirl.create(:audit, content_item: insurance)
    FactoryGirl.create(
      :response,
      question: FactoryGirl.create(:boolean_question),
      audit: insurance_audit,
      value: "yes"
    )
  end

  def width(id)
    page.find("#{id} .progress .progress-bar")[:style]
  end

  scenario "Displaying the number of items included in the audit" do
    visit audits_report_path
    expect(page).to have_content("3 Content items")

    select "Organisation", from: "document_type"
    click_on "Filter"
    expect(page).to have_content("1 Content items")

    select "Policy", from: "document_type"
    click_on "Filter"
    expect(page).to have_content("2 Content items")
  end

  scenario "Displaying the number of items audited/not audited" do
    visit audits_report_path

    expect(page).to have_content("Items audited 2 67%")
    expect(page).to have_content("Items still to audit 1 33%")
    expect(width("#progress")).to eq("width: 66.66667%;")
  end

  scenario "Displaying the number of items needing improvement/not needing improvement" do
    visit audits_report_path

    expect(page).to have_content("Items that need improvement 1 50%")
    expect(page).to have_content("Items that don't need improvement 1 50%")
    expect(width("#items-needing-improvement")).to eq("width: 50%;")
  end

  scenario "Audit status filter is not present" do
    visit audits_report_path

    expect(page).to have_no_content("Audit status")
  end
end
