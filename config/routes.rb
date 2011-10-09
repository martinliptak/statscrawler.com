StatscrawlerCom::Application.routes.draw do
  resources :domains do
    collection do
      get :search
      get :countries
    end

    member do
      get :whois
      get :pagerank
      get :analyze
    end
  end

  root :to => 'domains#index'
end
