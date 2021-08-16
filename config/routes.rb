Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'dashboards#index'

  post '/api_key', to: 'api_key#submit'
  post '/api_key/reset', to: 'api_key#reset'
end
