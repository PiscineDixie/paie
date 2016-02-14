# coding: utf-8
#
# Classe pour preparer une demande de rapports
#
class RapportsController < ApplicationController

  before_action :check_admin
  
  # La seule methode est "index". Elle affiche des "forms" qui
  # genere un URL pour le bon controller.
  def index
  end

end
