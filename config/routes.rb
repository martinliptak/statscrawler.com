StatscrawlerCom::Application.routes.draw do
  resources :lists
  resources :domains do
    get :search, :on => :collection

    member do
      get :whois
      get :pagerank
    end
  end

  root :to => 'lists#show#dmoz'
end
