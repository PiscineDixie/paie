# coding: utf-8
class PaiesController < ApplicationController

  # Use the common layout for all controllers
  layout "paie"

  before_action :load_deps
  before_action :check_admin
  
  
  def load_deps
    @periode = Periode.find(params[:periode_id])
  end
  
  # GET /paies
  # GET /paies.xml
  def index
    @paies = @periode.paies.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @paies }
    end
  end

  # GET /paies/1
  # GET /paies/1.xml
  def show
    @paie = @periode.paies.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @paie }
    end
  end

  # GET /paies/new
  # GET /paies/new.xml
  def new
    @paie = @periode.paies.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @paie }
    end
  end

  # GET /paies/1/edit
  def edit
    @paie = @periode.paies.find(params[:id])
    @paie.pre_fill
  end

  # POST /paies
  # POST /paies.xml
  def create
    @paie = @periode.paies.new(paie_params())

    respond_to do |format|
      if @paie.save
        flash[:notice] = 'Paie créée.'
        format.html { redirect_to([@periode, @paie]) }
        format.xml  { render :xml => @paie, :status => :created, :location => @paie }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @paie.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /paies/1
  # PUT /paies/1.xml
  def update
    @paie = @periode.paies.find(params[:id])

    respond_to do |format|
      if @paie.update_attributes(paie_params())
        flash[:notice] = 'Paie mise à jour.'
        format.html { redirect_to([@periode, @paie]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @paie.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /paies/1
  # DELETE /paies/1.xml
  def destroy
    @paie = @periode.find(params[:id])
    @paie.destroy

    respond_to do |format|
      format.html { redirect_to(periode_paies_url) }
      format.xml  { head :ok }
    end
  end
  
  
  # expedier un relevé de paie
  def releveCourriel
    @paie = Paie.find(params[:id])
    PaieMailer.releve(@paie).deliver_later
    flash[:notice] = 'Courriel expédié.'
    redirect_to periode_paie_path(@paie.periode, @paie)
  end

  private
  
  def paie_params
    params.require(:paie).pemit!
  end
end
