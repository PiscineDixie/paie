# coding: utf-8
# Model des constantes de pour la calcul des retenues de paies
#

class ConstantePaie < ApplicationRecord
  
  def self.instance
    return ConstantePaie.take
  end
end
