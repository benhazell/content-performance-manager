RSpec.describe ContentItemsController, type: :controller do
  include AuthenticationControllerHelpers

  before do
    allow_any_instance_of(MetricBuilder).to receive(:run_collection).and_return(a: :b)
    login_as_stub_user
  end

  describe "GET #index" do
    it "returns http success" do
      get :index

      expect(response).to have_http_status(:success)
    end

    it "assigns list of content items" do
      expect_any_instance_of(Queries::ContentItemsQuery).to receive(:paginated_results).and_return(double('collection', decorate: :the_results))
      get :index

      expect(assigns(:content_items)).to eq(:the_results)
    end

    it "assigns set of metrics" do
      expect_any_instance_of(MetricBuilder).to receive(:run_collection).and_return(a: :b)
      get :index

      expect(assigns(:metrics)).to eq(a: :b)
    end

    it "build the paged query with the expected params" do
      expected_params = { sort: 'title', order: 'asc', page: '1', taxon: nil, organisation: nil, query: 'a title' }
      result = double('collection', paginated_results: double(decorate: :the_results), results: [])

      expect(Queries::ContentItemsQuery).to receive(:new).with(expected_params).and_return(result)

      get :index, params: expected_params
    end

    it "build the unpaged query with the expected params" do
      expected_params = { sort: 'title', order: 'asc', page: '1', taxon: nil, organisation: nil, query: 'a title' }
      expect_any_instance_of(Queries::ContentItemsQuery).to receive(:results).and_return([])

      get :index, params: expected_params
    end

    it "assigns the organisation provided the content_id" do
      create(:organisation, content_id: 'the-organisation-id')

      get :index, params: { organisation_content_id: 'the-organisation-id' }
      expect(assigns(:organisation).content_id).to eq('the-organisation-id')
    end

    it "assigns the taxon provided by the taxon content id" do
      create(:taxon, content_id: "123")

      get :index, params: { taxon_content_id: "123" }
      expect(assigns(:taxon).content_id).to eq("123")
    end

    it "renders the :index template" do
      get :index

      expect(subject).to render_template(:index)
    end

    it "assigns the lists of taxons and organisations ordered ASC by title" do
      create(:organisation, title: "Z")
      create(:organisation, title: "A")
      create(:taxon, title: "Z")
      create(:taxon, title: "A")

      get :index

      expect(assigns(:organisations).count).to eq(2)
      expect(assigns(:organisations).first.title).to eq("A")
      expect(assigns(:taxons).count).to eq(2)
      expect(assigns(:taxons).first.title).to eq("A")
    end
  end

  describe "GET #show" do
    let(:content_item) { create(:content_item) }

    before do
      get :show, params: { id: content_item.id }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "assigns current content item" do
      expect(assigns(:content_item)).to eq(content_item)
    end

    it "decorates the content item" do
      expect(assigns(:content_item)).to be_decorated
    end

    it "renders the :show template" do
      expect(subject).to render_template(:show)
    end
  end
end
