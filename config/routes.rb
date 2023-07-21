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
  
  # social login
  get 'login', to: 'sessions#create', as: :create_login
  get 'signout', to: 'sessions#destroy', as: 'signout'
  
end
