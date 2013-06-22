Spree::Core::Engine.routes.draw do
  namespace :admin do
      resources :oxxos, :only => [:index, :new, :create], :path => 'oxxo'
  end
end
