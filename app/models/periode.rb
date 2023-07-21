# coding: utf-8
# Classe pour representer l'ensemble des paies pour une periode
#

require 'calcule_paie'

class Periode < ApplicationRecord
  
#  attr_accessible :debut
  
  validates_presence_of :debut
  validates_uniqueness_of :debut
  
  # Si on enleve une periode de paie, on enleve toutes les donnees
  has_many :paies, :dependent => :destroy
  
  # Valider que la date de debut de la periode correspond a une periode de paie
  validate :verifierDebut
  def verifierDebut
    employeur = Employeur.instance
    jour = (self.debut - employeur.debut_paie).day
    if jour.modulo(7 * employeur.semaines_par_paie) != 0
      errors.add(:debut, "La date du début de la période de paie doit correspondre avec la date de la première paye indiquée dans la fiche de l'employeur.")
    end
  end
  

  # Ajouter des donnees pour tous les employes
  def pre_fill
    employes = Employe.employesActif
    
    # Pour chaque employe, cree un objet Paie si inexistant
    employes.each do |empl|
      unless self.paies.exists?({employe_id: empl.id, periode_id: self.id})
        self.paies << Paie.new(:employe_id => empl.id, :periode_id => self.id)
      end
    end
  end

  
  # Faire le lien entre une paie et une feuille de temps
  def linkPaieToFeuille(p)
    if p.feuille_id.nil?
      f = Feuille.find_by("employe_id = ? and periode = ?", p.employe_id, self.debut)
      unless f.nil?
        p.feuille_id = f.id
      end
    end
  end
  
  
  # Faire le lien avec les feuilles de temps pour tous les employes
  def linkPaiesToFeuilles
    self.paies.each { |p| linkPaieToFeuille(p) }
  end


  # Calculer toutes les paies
  def calculPaie
    self.paies.each do |p|
      # Faire le lien avec la feuille de temps et la "geler"
      unless p.feuille_id.nil?
        f = Feuille.find(p.feuille_id)
        unless f.locked
          f.locked = true
          f.save!
        end
      end
      
      # Calculer la paie et la sauvegarder
      CalculePaie.calcul(p)
      p.setChequeNo unless p.total == 0
      p.save!
    end
    self.ae_employeur = (ae_employe_total * ConstantePaie.instance.aeTauxEmployeur * 100).round / 100.0
    self.rrq_employeur = (rrq_employe_total * ConstantePaie.instance.rrqTauxEmployeur * 100).round / 100.0
    self.rqap_employeur = (rqap_employe_total * ConstantePaie.instance.rqapTauxEmployeur * 100).round / 100.0
    self.fss_employeur = (brut_total * ConstantePaie.instance.fssTauxEmployeur * 100).round / 100.0
    self.csst_employeur = (brut_total * ConstantePaie.instance.csstTauxEmployeur * 100).round / 100.0
    self.save!
  end
  

  # On enleve une periode. Il faut alors remettre les feuilles de
  # temps modifiable
  def destroy
    cheque_min = 999999
    self.paies.each do |p|
      unless p.feuille_id.nil?
        f = Feuille.find(p.feuille_id)
        f.locked = false
        f.save!
      end
      cheque_min = p.cheque_no if !p.cheque_no.nil? && p.cheque_no < cheque_min
    end
    super
    
    # Recuperer le plus petit numero de cheque
    if Employeur.instance.prochain_no_cheque > cheque_min
      Employeur.instance.set_prochain_no_cheque(cheque_min)
    end
  end
  
  
  #
  # Fonctions pour calculer le total pour l'ensemble des paies
  #
  def total_total
    remb_depense_total + net_total
  end
  
  def net_total
    sum =  self.paies.sum(:net)
    sum.nil? ? 0 : sum
  end
  
  def brut_total
    sum =  self.paies.sum(:brut)
    sum.nil? ? 0 : sum
  end
  
  def remb_depense_total
    sum =  self.paies.sum(:remb_depense)
    sum.nil? ? 0 : sum
  end
  
  def ajustement_heures_total
    sum =  self.paies.sum(:ajustement_heures)
    sum.nil? ? 0 : sum
  end
  
  def autre_gain_imposable_total
    sum =  self.paies.sum(:autre_gain_imposable)
    sum.nil? ? 0 : sum

  end
  
  # Pour le total des heures travaillees, il faut demander a Paie parce que pas directement dans db
  def heures_total
    tot = 0
    self.paies.each do |p|
      tot = tot + p.heures
    end
    return tot
  end
  
  def ae_employe_total
    sum =  self.paies.sum(:ae)
    sum.nil? ? 0 : sum
  end
  
  def ae_employeur_total
    self.ae_employeur
  end
  
  def rrq_employe_total
    sum =  self.paies.sum(:rrq)
    sum.nil? ? 0 : sum
  end
  
  def rrq_employeur_total
    self.rrq_employeur
  end

  def rqap_employe_total
    sum =  self.paies.sum(:rqap)
    sum.nil? ? 0 : sum
  end
  
  def rqap_employeur_total
    self.rqap_employeur
  end

  def fss_employeur_total
    self.fss_employeur
  end

  def csst_employeur_total
    self.csst_employeur
  end

  def impot_fed_employe_total
    sum =  self.paies.sum(:impot_fed)
    sum.nil? ? 0 : sum
  end
  
  def impot_prov_employe_total
    sum =  self.paies.sum(:impot_prov)
    sum.nil? ? 0 : sum
  end
  
  # Methode pour faire la somme d'une colonne pour un intervalle
  # Arguments de type Date
  def self.total(debut, fin, colonne)
    Periode.
      where("debut >= :minDate and debut <= :endDate", 
        {:minDate => debut.to_formatted_s(:db), :endDate => fin.to_formatted_s(:db)}).
      sum(colonne)
  end
  
  # Methode pour trouver les annees pour laquelles nous avons des donnees
  def self.annees
    res = Array.new
    derniere = -1
    Periode.all.order(:debut).each do | p |
      if derniere < p.debut.year
        derniere = p.debut.year
        res << derniere
      end
    end
    return res
  end
  
  # Date tout de suite apres la periode de paie
  def fin
    empl = Employeur.instance
    return self.debut + 7 * empl.semaines_par_paie
  end
  
  def dernierJour
    return fin - 1
  end

end
