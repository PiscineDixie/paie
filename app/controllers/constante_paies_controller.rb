# coding: utf-8
class ConstantePaiesController < ApplicationController

  before_action :check_admin
  
  # GET /constante_paies/1
  def show
    @constante_paie = ConstantePaie.take
    if @constante_paie.nil?
      @constante_paie = ConstantePaie.new
      render :action => "new"
      return
    end
  end

  # GET /constante_paies/new
  # GET /constante_paies/new.xml
  def new
    @constante_paie = ConstantePaie.new
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
    
    if @constante_paie.save
      flash[:notice] = 'ConstantePaie was successfully created.'
      redirect_to(@constante_paie)
      return
    else
      render :action => "new"
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
    
    if @constante_paie.update(constante_paie_params())
      flash[:notice] = 'ConstantePaie was successfully updated.'
      redirect_to(@constante_paie)
    else
      render :action => "edit"
    end
  end

  private
  
  def constante_paie_params
    params.require(:constante_paie).permit!()
  end
end
