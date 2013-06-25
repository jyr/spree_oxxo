Spree::Core::Engine.routes.draw do
  namespace :admin do
      resources :oxxos, :path => 'oxxo'
  end
end
