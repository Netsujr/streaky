Rails.application.routes.draw do
  root "dashboard#show"

  get "/sign_up", to: "registrations#new"
  post "/sign_up", to: "registrations#create"

  get "/sign_in", to: "sessions#new"
  post "/sign_in", to: "sessions#create"
  delete "/sign_out", to: "sessions#destroy"

  get "/settings", to: "settings#show"
  patch "/settings", to: "settings#update"

  resources :habits, except: [:edit] do
    member do
      patch :archive
    end
    collection do
      get :archived
    end
    resources :checkins, only: [] do
      collection do
        post :toggle
      end
    end
  end

  post "/habits/:habit_id/toggle_checkin", to: "checkins#toggle", as: :toggle_checkin
end
