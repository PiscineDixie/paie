# coding: utf-8

require 'matrice_heures'

class FeuilleGroupesController < ApplicationController

  before_action :check_admin
  
  # Use the common layout for all controllers
  layout "paie"

# GET /feuille_groupes
  # Afficher toutes les dates possibles.
  def index
    @dates = FeuilleGroupe.candidates
  end

  # Afficher pour une date
  # GET /feuille_groupes/:date
  def show
    # params[:date] est la date du debut de la periode. 
    @feuille_groupe = FeuilleGroupe.new(params[:id].to_date)
  end

  def sommaire
    @feuille_groupe = FeuilleGroupe.new(params[:id].to_date)
    @fgSH = MatriceHeures.new(@feuille_groupe.debut, @feuille_groupe.fin)
    @ra = RapportActivites.new(@feuille_groupe.debut, @feuille_groupe.fin)
  end
  
  # Operations pour empecher la modification des feuilles de temps par les employes
  def employeLock
    @feuille_groupe = FeuilleGroupe.new(params[:id].to_date)
    @feuille_groupe.employeLock
    flash[:notice] = 'Les feuilles de temps ne peuvent plus être modifiées par les employés.'
    redirect_to action: :show
  end
  
  # Operations pour permettre la modification des feuilles de temps par les employes
  def employeUnlock
    @feuille_groupe = FeuilleGroupe.new(params[:id].to_date)
    @feuille_groupe.employeUnlock
    flash[:notice] = 'Les feuilles de temps peuvent être modifiées par les employés.'
    redirect_to action: :show
  end
  
  # Rapport des heures-activites pour une plage de jours
  # params[:debut] - date du debut du rapport
  # params[:fin] - dernier jour inclus dans rapport
  def heures
    debut = Date.parse(params['debut'])
    fin   = Date.parse(params['fin']).tomorrow
    @ra = RapportActivites.new(debut, fin)
    #render(:layout => 'vide')
  end
end
