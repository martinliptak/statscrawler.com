StatscrawlerCom::Application.routes.draw do
  resources :lists
  resources :domains do
    get :search, :on => :collection
  end

  root :to => 'lists#show#dmoz'
end
