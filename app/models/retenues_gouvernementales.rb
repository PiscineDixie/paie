# coding: utf-8
# Modele pour le rapport des retenues gouvernementales pour une ou plusieurs periodes de paie
#
class RetenuesGouvernementales
  
  attr_reader :debut
  attr_reader :fin
  attr_reader :brut
  attr_reader :ae
  attr_reader :rrq
  attr_reader :rqap
  attr_reader :fss
  attr_reader :csst
  attr_reader :impot_fed
  attr_reader :impot_prov
  
  # Creer l'objet. Les arguments sont des dates correspondant a des periodes
  def initialize(debut, fin)
    # Init accumulators
    @brut = @ae = @rrq = @rqap = @fss = @csst = @impot_fed = @impot_prov = 0
    @debut = debut
    @fin = fin
    
    # Extraire les periodes correspondants aux dates
    ps = Periode.where("debut >= :minDate and debut <= :endDate", {:minDate => debut, :endDate => fin})
    
    # Maintenant faire le total de toutes ces periodes de paie
    ps.each do |p|
      @brut += p.brut_total
      @ae += p.ae_employeur_total + p.ae_employe_total
      @rrq += p.rrq_employeur_total + p.rrq_employe_total
      @rqap += p.rqap_employeur_total + p.rqap_employe_total
      @fss  += p.fss_employeur_total
      @csst  += p.csst_employeur_total
      @impot_fed += p.impot_fed_employe_total
      @impot_prov += p.impot_prov_employe_total
    end
  end
  
  def total_prov
    return @rrq + @rqap + @fss + @csst + @impot_prov
  end
  
  def total_fed
    return @ae + @impot_fed
  end
end