# coding: utf-8
# Modele pour les transactions dans le grand livre pour une periode de paie
#
class TransactionsGL
  
  attr_reader :brut
  attr_reader :net
  attr_reader :ae_depense
  attr_reader :ae_passif
  attr_reader :rrq_depense
  attr_reader :rrq_passif
  attr_reader :rqap_depense
  attr_reader :rqap_passif
  attr_reader :fss_depense
  attr_reader :fss_passif
  attr_reader :csst_depense
  attr_reader :csst_passif
  attr_reader :impot_fed_passif
  attr_reader :impot_prov_passif
  
  # Creer l'objet a partir de l'information de la periode
  def initialize(periode)
    @brut = periode.brut_total
    @net  = periode.net_total
    @ae_depense = periode.ae_employeur_total
    @ae_passif = @ae_depense + periode.ae_employe_total
    @rrq_depense = periode.rrq_employeur_total
    @rrq_passif = @rrq_depense + periode.rrq_employe_total
    @rqap_depense = periode.rqap_employeur_total
    @rqap_passif = @rqap_depense + periode.rqap_employe_total
    @fss_passif = @fss_depense = periode.fss_employeur_total
    @csst_passif = @csst_depense = periode.csst_employeur_total
    @impot_fed_passif = periode.impot_fed_employe_total
    @impot_prov_passif = periode.impot_prov_employe_total
  end
end