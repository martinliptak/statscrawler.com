StatscrawlerCom::Application.routes.draw do
  resources :lists
  resources :domains

  root :to => 'lists#show#dmoz'
end
