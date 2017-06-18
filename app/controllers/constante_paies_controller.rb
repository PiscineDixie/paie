# coding: utf-8
class ConstantePaiesController < ApplicationController

  before_action :check_admin
  
  # GET /constante_paies/1
  def show
    @constante_paie = ConstantePaie.take
    if @constante_paie.nil?
      @constante_paie = ConstantePaie.new
      render :action => "new"
    end
  end

  # GET /constante_paies/new
  # GET /constante_paies/new.xml
  def new
    @constante_paie = ConstantePaie.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @constante_paie }
    end
  end

  # GET /constante_paies/1/edit
  def edit
    @constante_paie = ConstantePaie.find(params[:id])
  end

  # POST /constante_paies
  # POST /constante_paies.xml
  def create
    @constante_paie = ConstantePaie.new(constante_paie_params())

    if (params[:cancel])
      redirect_to(@constante_paie)
      return;
    end
    
    respond_to do |format|
      if @constante_paie.save
        flash[:notice] = 'ConstantePaie was successfully created.'
        format.html { redirect_to(@constante_paie) }
        format.xml  { render :xml => @constante_paie, :status => :created, :location => @constante_paie }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @constante_paie.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /constante_paies/1
  # PUT /constante_paies/1.xml
  def update
    @constante_paie = ConstantePaie.find(params[:id])

    if (params[:cancel])
      redirect_to(@constante_paie)
      return;
    end
    
    respond_to do |format|
      if @constante_paie.update(constante_paie_params())
        flash[:notice] = 'ConstantePaie was successfully updated.'
        format.html { redirect_to(@constante_paie) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @constante_paie.errors, :status => :unprocessable_entity }
      end
    end
  end

  private
  
  def constante_paie_params
    params.require(:constante_paie).permit(
      :impFedI1, :impFedR1, :impFedK1,
      :impFedI2, :impFedR2, :impFedK2,
      :impFedI3, :impFedR3, :impFedK3,
      :impFedR4, :impFedK4, :deductionBaseFed,
      :impProvI1, :impProvT1, :impProvK1,
      :impProvI2, :impProvT2, :impProvK2,
      :impProvT3, :impProvK3, :deductionBaseProv,
      :aeTauxEmploye, :aeMaximumEmploye, :aeMaximumGainAssurable, :aeTauxEmployeur,
      :rrqTauxEmploye, :rrqMaximumEmploye, :rrqTauxEmployeur, :rrqExemptionEmploye,
      :rqapTauxEmploye, :rqapMaximumEmploye, :rqapTauxEmployeur, 
      :fssTauxEmployeur, :csstTauxEmployeur)
  end
end
