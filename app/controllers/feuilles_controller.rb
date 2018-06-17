# coding: utf-8
require 'matrice_heures'

class FeuillesController < ApplicationController
  
  before_action :set_auto_employe
  def set_auto_employe
    @employe = nil
    return true if User.hasAdminPriviledge(session[:user])
    @employe = Employe.find_by_id(session[:employe])
    return @employe != nil
  end
  
  class InvalideUserFeuille < StandardError
  end
  
  rescue_from InvalideUserFeuille, :with => :feuille_user_mismatch
  def feuille_user_mismatch(exception)
    flash[:notice] = "Vous ne pouvez accéder que vos propres feuilles de temps."
    redirect_to "/"
  end
    
  # Use the common layout for all controllers
  layout "paie"

  # GET /feuilles/1
  def show
    @feuille = validateBelongsToEmploye(Feuille.find(params[:id]))
  end

  # GET /feuilles/new
  def new
    @feuille = Feuille.new({:employe_id => params[:employe_id], :periode => params[:periode].to_date})
  end

  # GET /feuilles/1/edit
  def edit
    @feuille = validateBelongsToEmploye(Feuille.find(params[:id]))
  end

  # POST /feuilles
  # POST /feuilles.xml
  def create
    
    jourVal = params[:feuille].delete(:jours)
    periode = params[:feuille][:periode] = Date.parse(params[:feuille].delete(:periode))
    params[:feuille][:heures] =  Feuille.getHeures(periode, jourVal) unless jourVal.nil?
      
    if (params[:cancel])
      backToFeuilleGroupe(periode)
      return;
    end

    @feuille = Feuille.new(params.require(:feuille).permit!)
    if @feuille.save
      flash[:notice] = 'Feuille de temps créée.'
      backToFeuilleGroupe(@feuille.periode)
    else
      @feuille.jourVar = jourVal;
      render :action => "new"
    end
  end

  # PUT /feuilles/1
  # PUT /feuilles/1.xml
  def update
    @feuille = validateBelongsToEmploye(Feuille.find(params[:id]))
      
    if (params[:cancel])
      redirect_to(@feuille)
      return;
    end
    
    heures = Feuille.getHeures(@feuille.periode, params[:feuille][:jours])
    heures = @feuille.replaceWithDbHeures(heures)
    if @feuille.heuresValidations(heures)
      @feuille.heures = heures;
      flash[:notice] = 'Feuille de temps mise à jour.'
      backToFeuilleGroupe(@feuille.periode)
    else
      @feuille.jourVar = params[:feuille][:jours]
      render :action => "edit"
    end
  end

  # DELETE /feuilles/1
  def destroy
    @feuille = validateBelongsToEmploye(Feuille.find(params[:id]))
    periode = @feuille.periode
    @feuille.destroy
    backToFeuilleGroupe(periode)
  end
  
  # Afficher les heures sous forme de tableau
  def sommaire
    @feuille = Feuille.find(params[:id])
    @mt = MatriceHeures.new(@feuille.debut, @feuille.fin, @feuille.employe_id)
    @ra = RapportActivites.new(@feuille.debut, @feuille.fin, @feuille.employe_id)
  end
  
  private
  
  def backToFeuilleGroupe(periode)
    if @employe.nil?
      redirect_to(:controller => '/feuille_groupes', :action => 'show', :id => periode.to_s(:db))
    else
      redirect_to '/'
    end
  end
  
  def validateBelongsToEmploye(feuille)
    return feuille if @employe == nil
    return feuille if @employe.id == feuille.employe_id
    raise InvalideUserFeuille
  end
end
