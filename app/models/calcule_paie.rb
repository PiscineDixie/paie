# coding: utf-8
# Objet pour faire le calcul d'une paie
# Input: 
class CalculePaie

  # Mettre a jour un objet Paie. L'ordre des operations est important.
  def self.calcul(aPaie)
    ctes = ConstantePaie.instance
    employeur = Employeur.instance
    employe = Employe.find(aPaie.employe_id)
    periode = Periode.find(aPaie.periode_id)
    CalculePaie.calculBrut(employe, aPaie)
    CalculePaie.calculAE(ctes, employe, periode, aPaie)
    CalculePaie.calculRQAP(ctes, employe, periode, aPaie)
    CalculePaie.calculRRQ(ctes, employeur, employe, periode, aPaie)
    CalculePaie.calculImpFed(ctes, employeur, employe, aPaie)
    CalculePaie.calculImpProv(ctes, employeur, employe, aPaie)
    CalculePaie.calculNet(aPaie)
  end
  
  def self.min(a,b)
    return a > b ? b : a
  end
  
  def self.max(a, b)
    return a > b ? a : b
  end
  
  # Calcul du salaire brut
  def self.calculBrut(employe, aPaie)
    heuresTravailles = aPaie.ajustement_heures
    unless aPaie.feuille_id.nil?
      heuresTravailles = heuresTravailles + Feuille.find(aPaie.feuille_id).totalHeures
    end
    gainHeures = (employe.salaire_horaire * heuresTravailles * 100).round / 100.0
    aPaie.vacances = (gainHeures * 4).round / 100.0  # 4% pour la paie de vacances sur les heures travaillees
    aPaie.brut = gainHeures + aPaie.vacances + aPaie.autre_gain_imposable
  end
  
  # Calcul de la paie net
  def self.calculNet(aPaie)
    aPaie.net = aPaie.brut - aPaie.ae - aPaie.rrq - aPaie.rqap - aPaie.impot_fed - aPaie.impot_prov
  end
  
  # Calcul de l'assurance emploi
  def self.calculAE(ctes, empl, periode, aPaie)
    aeEmplAnnee = empl.ae_annuel(periode.debut.year)
    aPaie.ae = min(
      ctes.aeMaximumEmploye - aeEmplAnnee, 
      (ctes.aeTauxEmploye * min(aPaie.brut, ctes.aeMaximumGainAssurable) * 100).round / 100.0) 
  end
  
  # Calcul de l'assurance parentale
  def self.calculRQAP(ctes, empl, periode, aPaie)
    rqapEmplAnnee = empl.rqap_annuel(periode.debut.year)
    aPaie.rqap = min(
      ctes.rqapMaximumEmploye - rqapEmplAnnee, 
      (ctes.rqapTauxEmploye * min(aPaie.brut, ctes.aeMaximumGainAssurable) * 100).round / 100.0) 
  end
  
  # Calcul du regime de retraite - RRQ
  def self.calculRRQ(ctes, employeur, empl, periode, aPaie)
    aPaie.rrq = 0
    
    return if empl.exempte_rrq(periode.debut)
    
    rrqEmplAnnee = empl.rrq_annuel(periode.debut.year)
    aPaie.rrq = min(
      ctes.rrqMaximumEmploye - rrqEmplAnnee, 
      (ctes.rrqTauxEmploye * (aPaie.brut - ctes.rrqExemptionEmploye * employeur.semaines_par_paie / 52.0 ) * 100).round / 100.0) 
    aPaie.rrq = 0 if aPaie.rrq < 0
  end
  
  # Calcul de l'impot federal
  def self.calculImpFed(ctes, employeur, employe, aPaie)
    aPaie.impot_fed = 0
    return if employe.exempte_impot
    
    # Calcul du revenu annuel
    p = 52.0 / employeur.semaines_par_paie
    i = aPaie.brut
    f = f2 = f1 = hd = u1 = 0.0
    a =  (p * (i - f - f2 -u1)) - hd -f1
    return unless a > 0

    
    # Calcul des facteurs d'impot selon le revenu
    k = r = 0.0
    k = ctes.impFedK1
    k = ctes.impFedK2 if a > ctes.impFedI1
    k = ctes.impFedK3 if a > ctes.impFedI2
    k = ctes.impFedK4 if a > ctes.impFedI3
    r = ctes.impFedR1
    r = ctes.impFedR2 if a > ctes.impFedI1
    r = ctes.impFedR3 if a > ctes.impFedI2
    r = ctes.impFedR4 if a > ctes.impFedI3
    
    k1 = k2 = k3 = k4 = t3 = 0.0
    k1 = (ctes.impFedR1 * employe.exemption_fed * 100).round / 100.0  # Devrait
    k2 = ((15 * min(p * aPaie.rrq,  ctes.rrqMaximumEmploye)) + 
          (15 * min(p * aPaie.ae,   ctes.aeMaximumEmploye)) +
          (15 * min(p * aPaie.rqap, ctes.rqapMaximumEmploye))).round / 100.0
    k4 = (0.15 * min(a, 1019) * 100).round / 100.0
    t3 = (r * a * 100).round / 100.0 - k - k1 - k2 - k3 - k4
    t3 = 0 if t3 < 0
    
    abattement = (0.165 * t3 * 100).round / 100.0
    t1 = t3 - abattement
    aPaie.impot_fed = (100 * t1 / p).round / 100.0
  end
  
  # Calcul de l'impot provincial
  def self.calculImpProv(ctes, employeur, employe, aPaie)
    aPaie.impot_prov = 0
    return if employe.exempte_impot
    
    p = 52.0 / employeur.semaines_par_paie
    
    # Calcul du revenu imposable annuel
    g = aPaie.brut
    h = (min(1000 / p, 0.06 * g) * 100).round / 100.0
    f = j = j1 = 0
    i  = (((p * (g -f -h)) -j -j1) * 100).round / 100.0
    
    # Calcul de l'impot pour l'annee
    t = ctes.impProvT1
    t = ctes.impProvT2 if i > ctes.impProvI1
    t = ctes.impProvT3 if i > ctes.impProvI2
    k = ctes.impProvK1
    k = ctes.impProvK2 if i > ctes.impProvI1
    k = ctes.impProvK3 if i > ctes.impProvI2
    k1 = 0
    e1 = employe.exemption_prov
    e2 = 0
    
    # Le 'e' est arrondi au multiple de 5 le plus pres
    e = e1 * 100 # On n'indexe pas
    e.modulo(500) >= 250 ? e = e + 500 - e.modulo(500) : e = e - e.modulo(500)
    e = e / 100.0 + e2
    
    y = ((t * i - k -k1 - 0.20 * e) * 100).round / 100.0 # - 0.15 * q
    y = 0 if y < 0
    
    # Calcul pour la periode de paie courante
    l = 0
    aPaie.impot_prov = (100 * y/p).round / 100.0 + l
  end
  
end