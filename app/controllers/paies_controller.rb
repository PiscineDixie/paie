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
  end

  # GET /paies/1
  # GET /paies/1.xml
  def show
    @paie = @periode.paies.find(params[:id])
  end

  # GET /paies/new
  # GET /paies/new.xml
  def new
    @paie = @periode.paies.new
  end

  # GET /paies/1/edit
  def edit
    @paie = @periode.paies.find(params[:id])
    @paie.pre_fill
  end

  # POST /paies
  # POST /paies.xml
  def create
    if (params[:cancel])
      redirect_to(paies_url)
      return;
    end
    
    @paie = @periode.paies.new(paie_params())

    if @paie.save
      flash[:notice] = 'Paie créée.'
      redirect_to([@periode, @paie]) 
    else
      render :action => "new"
    end
  end

  # PUT /paies/1
  # PUT /paies/1.xml
  def update
    @paie = @periode.paies.find(params[:id])

    if (params[:cancel])
      redirect_to(@paie)
      return;
    end
    
    if @paie.update(paie_params())
      flash[:notice] = 'Paie mise à jour.'
      redirect_to([@periode, @paie]) 
    else
      render :action => "edit" 
    end
  end

  # DELETE /paies/1
  # DELETE /paies/1.xml
  def destroy
    @paie = @periode.find(params[:id])
    @paie.destroy
    redirect_to(periode_paies_url)
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
