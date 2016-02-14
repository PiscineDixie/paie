# coding: utf-8
# Model des constantes de pour la calcul des retenues de paies
#

class ConstantePaie < ActiveRecord::Base
  
  def self.instance
    return ConstantePaie.take
  end
end
