Rails.application.routes.draw do

  root to: 'home#show'
  match 'fill_details(/:action)' => 'fill_details', via: [:get, :post]

end
