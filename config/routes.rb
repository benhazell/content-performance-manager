Rails.application.routes.draw do
  root to: 'content_items#index'

  resources :groups, only: %w(show create index destroy), param: "slug"

  resources :content_items, only: %w(index show) do
    get :audit, to: "audits#show"
    post :audit, to: "audits#save"
    patch :audit, to: "audits#save"
  end

  resources :audits, only: %w(index)

  resources :taxonomy_projects, path: '/taxonomy-projects', only: %w(index show new create) do
    get 'next', on: :member
    get 'terms', on: :member, constraints: { format: 'json' }
  end

  resources :taxonomy_todos, only: %w(show update) do
    post 'dont_know', on: :member
    post 'not_relevant', on: :member
  end

  namespace :audits do
    get :report
    get :export
  end

  namespace :inventory do
    root action: "show"
    get :toggle, action: "toggle"
    post :themes, action: "add_theme"
    post :subthemes, action: "add_subtheme"
  end

  if Rails.env.development?
    mount GovukAdminTemplate::Engine, at: "/style-guide"
  end

  mount Proxies::GovernmentProxy.new => Proxies::GovernmentProxy::PROXY_BASE_PATH

end
