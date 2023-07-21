# coding: utf-8
#
# Controlleur pour gerer la liste des employes
#
class EmployesController < ApplicationController

  before_action :check_admin
  
  # Use the common layout for all controllers
  layout "paie"

  # GET /employes
  # GET /employes.xml
  def index
    @employes = Employe.where(etat: 'actif').order('nom, prenom')
  end
  
  def inactifs
    @employes = Employe.where(etat: 'inactif').order('nom, prenom')
    render :action => "index"
  end

  # GET /employes/1
  # GET /employes/1.xml
  def show
    @employe = Employe.find(params[:id])
  end

  # GET /employes/new
  # GET /employes/new.xml
  def new
    @employe = Employe.new
  end

  # GET /employes/1/edit
  def edit
    @employe = Employe.find(params[:id])
  end

  # POST /employes
  # POST /employes.xml
  def create
    if (params[:cancel])
      redirect_to(employes_url)
      return;
    end
    
    @employe = Employe.new(employe_params)

    if @employe.save
      flash[:notice] = 'Employé créé.'
      redirect_to(@employe)
    else
      render :action => "new"
    end
  end

  # PUT /employes/1
  # PUT /employes/1.xml
  def update
    @employe = Employe.find(params[:id])

    if (params[:cancel])
      redirect_to(@employe)
      return;
    end
    
    if @employe.update(employe_params())
      flash[:notice] = 'Employé mis à jour.'
      redirect_to(@employe)
    else
      render :action => "edit"
    end
  end

  # DELETE /employes/1
  # DELETE /employes/1.xml
  def destroy
    @employe = Employe.find(params[:id])
    @employe.etat = 'inactif'
    @employe.save!
    redirect_to(employes_url)
  end

  private
  
  def employe_params
    params.require(:employe).permit!
  end
end
