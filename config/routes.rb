Rails.application.routes.draw do
  resources :constante_paies
  
#  get 'feuilles_groupes/:date' => 'feuilles_groupes#show'
#  get 'feuilles_groupes/:date/sommaire' => 'feuilles_groupes#sommaire'
#  get 'feuilles_groupes/heures' => 'feuilles_groupes#heures'
#  get 'feuilles_groupes/' => 'feuilles_groupes#index'
  
  get '/' => 'root#index'
  root to: 'root#index'
  
  get 'instructions' => 'root#instructions'
  
  get 'auto' => 'auto#index'
  get 'auto/feuille_new'
  
  resources :feuille_groupes do
    collection do
      post 'heures'
    end
    member do
      get 'sommaire'
      post 'employeLock'
      post 'employeUnlock'
    end
  end

  get 'rapports' => 'rapports#index'

  get 'periodes/annees/:an' => 'periodes#annees'
  
  get 'heures/autravail' => 'heures/autravail'
  
  resources :feuilles do
    member do
      get 'sommaire'
    end
  end

  resources :employeurs do
    member do
      post 't4', :defaults => { :format => 'pdf' }
      post 'rl1', :defaults => { :format => 'pdf' }
      post 'salaires'
      post 'rapport_paies'
    end
  end

  resources :employes do
    collection do
      get 'inactifs'
    end
  end

  resources :periodes do
    resources :paies do
      member do
        post 'releveCourriel'
      end
    end
    member do
      get 'calculer'
      get 'sommaire'
      get 'cheques', :defaults => { :format => 'pdf' }
      get 'gl'
      post 'employeCourriels'
    end
    collection do
      post 'gouv'
    end
  end

  resources :users
  
  post 'auth/:provider/callback', to: 'sessions#create'
  post 'auth/failure', to: 'sessions#reject'
  get 'signout', to: 'sessions#destroy', as: 'signout'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
