Rails.application.routes.draw do
  devise_for :users
  root 'home#index'
  scope :admin do
    get 'details', to: 'home#details'
  end
  scope :api do
    scope :v1 do
      post 'signin', to: 'api#signin'
      post 'signup', to: 'api#signup'

      # friend management
      scope :friends do
        post 'add', to: 'api#add_friend'
        post 'pending', to: 'api#list_pending_friend_request'
        post 'accept', to: 'api#accept_friend_request'
        post 'friends', to: 'api#my_friends'
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
