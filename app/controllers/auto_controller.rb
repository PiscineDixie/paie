#
# Controlleur pour les operations d'un employe dans son dossier
#
   
class AutoController < ApplicationController
  
  layout "paie"
  
  protect_from_forgery
  
  before_action :authenticate
  
  # Filtre pour s'assurer que l'employe a fait le login
  def authenticate
    @employe = Employe.find_by_id(session[:employe] || 0)
    return if @employe
    flash[:notice] = "Vous devez faire un login."
    redirect_to root_url
  end
  
  def index
    # Generer un hash pour chacunes des dates ainsi que leurs feuilles
    @feuilles = {}
      
    dates = FeuilleGroupe.candidates
    @employe.feuilles_range(dates[0], dates[-1]).each do | f|
      @feuilles[f.periode] = f
    end
    
    # Ajouter une feuille ou il n'y en a pas encore
    now = Date.today
    dates.each do | date |
      if !@feuilles.has_key?(date) && date <= now
        @feuilles[date] = Feuille.new({:employe_id => @employe.id, :periode => date.to_formatted_s(:db)})
      end
    end
  end
  
end