Surveyor::Application.routes.draw do
  get "map" => "map#index"

  root "map#index"
end
