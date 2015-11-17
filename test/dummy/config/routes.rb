Rails.application.routes.draw do

  root to: 'home#show'
  match 'demo(/:action)' => 'demo', via: [:get, :post]
  get 'about' => 'about#show'

end
