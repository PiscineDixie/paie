# coding: utf-8
class EmployeursController < ApplicationController

  before_action :check_admin
  
  # Use the common layout for all controllers
  layout "paie"

  # GET /employeurs/1
  # GET /employeurs/1.xml
  def show
    @employeur = Employeur.take
    if @employeur.nil?
      @employeur = Employeur.new
      render :action => "new"
    end
  end

  # GET /employeurs/new
  # GET /employeurs/new.xml
  def new
    @employeur = Employeur.new
  end

  # GET /employeurs/1/edit
  def edit
    @employeur = Employeur.find(params[:id])
  end

  # POST /employeurs
  # POST /employeurs.xml
  def create
    @employeur = Employeur.new(employeur_params())

    if @employeur.save
      flash[:notice] = 'Employeur was successfully created.'
      redirect_to(@employeur)
    else
      render :action => "new"
    end
  end

  # PUT /employeurs/1
  # PUT /employeurs/1.xml
  def update
    @employeur = Employeur.find(params[:id])

    if (params[:cancel])
      redirect_to(@employeur)
      return;
    end
    
    if @employeur.update(employeur_params())
      flash[:notice] = 'Employeur was successfully updated.'
      redirect_to(@employeur)
    else
      render :action => "edit" 
    end
  end

  # Les T4 pour une annee
  # params[:annee] - annee desiree (e.g. 2008)
  # params[:dest] - destinataire du rapport: "gouvernement, employe"
  def t4
    annee = params[:annee].to_i
    copies = (params[:dest] == 'employe' ? 2 : 1)
    employeur = Employeur.find(params[:id])
    doc = Prawn::Document.new(:skip_page_creation => true, :margin => 0)
    T4.renderMultiple(doc, Employe.employesPayes(annee), employeur, annee, copies)
    send_data doc.render, :filename => 't4-' + annee.to_s + '.pdf', :type => 'application/pdf', :disposition => 'inline'
  end
  
  # Les RL1 pour une annee
  # params[:annee] - annee desiree (e.g. 2008)
  def rl1
    annee = params[:annee].to_i
    employeur = Employeur.find(params[:id])
    doc = Prawn::Document.new(:skip_page_creation => true, :margin => 0, :page_size => 'LETTER')
    Rl1.renderMultiple(doc, Employe.employesPayes(annee), employeur, annee);
    send_data doc.render, :filename => 'rl1-' + annee.to_s + '.pdf', :type => 'application/pdf', :disposition => 'inline'
  end
  
  # Les gains des employés pour l'intervalle donnée
  # params[:debut] - date du début du rapport
  # params[:fin] - date de la find du rapport
  def salaires
    @employeur = Employeur.find(params[:id])
    @debut = Date.parse(params['debut'])
    @fin   = Date.parse(params['fin'])
  end
  
  # Rapports des periodes de paie de l'intervalle donne. Avec totaux
  # params[:debut] - date du début du rapport
  # params[:fin] - date de la find du rapport
  def rapport_paies
    @employeur = Employeur.find(params[:id])
    @debut = Date.parse(params['debut'])
    @fin   = Date.parse(params['fin'])
  end


  private
  
  def employeur_params
    params.require(:employeur).permit!
  end
end
