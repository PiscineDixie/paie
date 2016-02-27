# coding: utf-8

require 'transactionsgl.rb'

class PeriodesController < ApplicationController

  # Use the common layout for all controllers
  layout "paie"

  before_action :check_admin
  
  # GET /periodes
  # GET /periodes.xml
  def index
    @periodes = {}
    dates = FeuilleGroupe.candidates
    Periode.where("debut >= ?", Date.new(Date.today().year, 1, 1)).each do | p |
      @periodes[p.debut] = p
    end
    
    # Ajouter une periode ou il n'y en a pas encore
    now = Date.today
    dates.each do | date |
      if !@periodes.has_key?(date) && date <= now
        @periodes[date] = Periode.new({debut: date})
      end
    end
    @periodes = @periodes.values
  end
  
  def annees
    an = params[:an].to_i
    @periodes = Periode.where("debut >= :start and debut < :fin", {:start => Date.new(an, 1, 1), :fin => Date.new(an+1, 1, 1)})
    render :action => 'index'
  end
  

  # GET /periodes/1
  # GET /periodes/1.xml
  def show
    @periode = Periode.find(params[:id])
    @periode.linkPaiesToFeuilles
  end

  # GET /periodes/new
  # GET /periodes/new.xml
  def new
    @periode = Periode.new
  end

  # GET /periodes/1/edit
  def edit
    @periode = Periode.find(params[:id])
    @periode.pre_fill
    @periode.linkPaiesToFeuilles
  end

  # POST /periodes
  # POST /periodes.xml
  def create
    
    if (params[:cancel])
      redirect_to(periodes_url)
      return;
    end
    
    date = Date.parse(params[:debut])
    @periode = Periode.new(:debut => date)

    if @periode.save
      flash[:notice] = 'Période de paie créée.'
      redirect_to edit_periode_path(@periode)
    else
      render :action => "new"
    end
  end

  # PUT /periodes/1
  # PUT /periodes/1.xml
  def update
    @periode = Periode.find(params[:id])

    if (params[:cancel])
      redirect_to(periodes_url)
      return;
    end
    
    if Paie.update(params[:paie].keys, params[:paie].values)
      flash[:notice] = 'Période de paie modifiée.'
      redirect_to(@periode)
    else
      render :action => "edit"
    end
  end

  # DELETE /periodes/1
  # DELETE /periodes/1.xml
  def destroy
    @periode = Periode.find(params[:id])
    @periode.destroy
    redirect_to(periodes_url)
  end
    
  # calculer la paie
  def calculer
    @periode = Periode.find(params[:id])
    @periode.linkPaiesToFeuilles
    @periode.calculPaie
    render :action => "show"
  end

  # impression d'un seul cheque ou de tous les cheques
  # d'une periode de paie
  def cheques
    @periode = Periode.find(params[:id])
    
    doc = Prawn::Document.new(:skip_page_creation => true)
    if params.key?(:paie_id)
      Cheque.render(doc, Paie.find(params[:paie_id]))
    else
      @periode.paies.each { |paie| Cheque.render(doc, paie) }
    end
    send_data doc.render, :filename => 'cheques-' + @periode.debut.to_s(:db) + '.pdf', :type => 'application/pdf', :disposition => 'inline'
    
    # Impossible de changer apres  impression des cheques
    @periode.locked = true;
    @periode.save!
  end
  

  # imprimer le sommaire de la periode
  def sommaire
    @periode = Periode.find(params[:id])
    @periode.linkPaiesToFeuilles
    render(:layout => 'vide')
  end

  # obtenir les transactions pour le grand livre de la periode
  def gl
    @periode = Periode.find(params[:id])
    @periode.linkPaiesToFeuilles
    @gl = TransactionsGL.new(@periode) 
  end

  # Generer un rapport des retenues gouvernementales pour les periodes donnee
  #  params[:premiere] - date de la premiere periode, e.g., 2008-02-21
  #  params[:derniere] - date de la derniere date (inclusivement), e.g., 2008-04-15
  def gouv
    debut = params[:premiere].to_date
    fin   = params[:derniere].to_date
    @rG = RetenuesGouvernementales.new(debut, fin)
  end
  
  # expedier les courriels pour les releves de paie
  def employeCourriels
    @periode = Periode.find(params[:id])
    @periode.paies.each do  | paie |
      PaieMailer.releve(paie).deliver_later unless paie.employe.courriel.empty? || paie.total == 0
    end
    # Puisque nous avons expedie des courriels, il est impossible de changer la paie.
    @periode.locked = true;
    @periode.save!
    flash[:notice] = 'Courriels expédiés.'
    redirect_to @periode
  end
  
  private
  def periode_params
    params.pemit(:id, :periode)
  end
end
