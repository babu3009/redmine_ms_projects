# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  #resources :msprojects
  match ':controller(/:action(/:project_id))', :controller => /msprojects/
end
