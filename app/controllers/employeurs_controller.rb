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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @employeur }
    end
  end

  # GET /employeurs/1/edit
  def edit
    @employeur = Employeur.find(params[:id])
  end

  # POST /employeurs
  # POST /employeurs.xml
  def create
    @employeur = Employeur.new(employeur_params())

    respond_to do |format|
      if @employeur.save
        flash[:notice] = 'Employeur was successfully created.'
        format.html { redirect_to(@employeur) }
        format.xml  { render :xml => @employeur, :status => :created, :location => @employeur }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @employeur.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /employeurs/1
  # PUT /employeurs/1.xml
  def update
    @employeur = Employeur.find(params[:id])

    respond_to do |format|
      if @employeur.update_attributes(employeur_params())
        flash[:notice] = 'Employeur was successfully updated.'
        format.html { redirect_to(@employeur) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @employeur.errors, :status => :unprocessable_entity }
      end
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
    T4.renderMultiple(doc, Employe.employesActif, employeur, annee, copies)
    send_data doc.render, :filename => 't4-' + annee.to_s + '.pdf', :type => 'application/pdf', :disposition => 'inline'
  end
  
  # Les RL1 pour une annee
  # params[:annee] - annee desiree (e.g. 2008)
  def rl1
    annee = params[:annee].to_i
    employeur = Employeur.find(params[:id])
    doc = Prawn::Document.new(:skip_page_creation => true, :margin => 0, :page_size => 'LETTER')
    RL1.renderMultiple(doc, Employe.employesActif, employeur, annee);
    send_data doc.render, :filename => 'rl1-' + annee.to_s + '.pdf', :type => 'application/pdf', :disposition => 'inline'
  end
  
  # Les gains des employés pour l'intervalle donnée
  # params[:debut] - date du début du rapport
  # params[:fin] - date de la find du rapport
  def salaires
    @employeur = Employeur.find(params[:id])
    @debut = Date.new(params['debut']['year'].to_i, params['debut']['month'].to_i, params['debut']['day'].to_i)
    @fin   = Date.new(params['fin']['year'].to_i, params['fin']['month'].to_i, params['fin']['day'].to_i)
  end
  
  # Rapports des periodes de paie de l'intervalle donne. Avec totaux
  # params[:debut] - date du début du rapport
  # params[:fin] - date de la find du rapport
  def rapport_paies
    @employeur = Employeur.find(params[:id])
    @debut = Date.new(params['debut']['year'].to_i, params['debut']['month'].to_i, params['debut']['day'].to_i)
    @fin   = Date.new(params['fin']['year'].to_i, params['fin']['month'].to_i, params['fin']['day'].to_i)
  end


  private
  
  def employeur_params
    params.require(:employeur).permit!
  end
end
