# coding: utf-8
class Paie < ActiveRecord::Base
  
#  attr_accessible :cheque_no, :remb_depense, :ajustement_heures, :autre_gain_imposable
#  attr_accessible :employe_id, :periode_id, :note
  
  belongs_to :periode
  belongs_to :employe
  belongs_to :feuille, optional: true
  
  #after_initialize :init
  def init
    if self.autre_gain_imposable.nil?
      self.autre_gain_imposable = 0
    end
  end
  
  # Valider que le numero de cheque n'est pas trop eleve, ajuster si necessaire
  after_save :updNoCheque
  def updNoCheque
    employeur = Employeur.instance
    unless self.cheque_no.nil? || self.cheque_no == 0
      if self.cheque_no >= employeur.prochain_no_cheque
        employeur.prochain_no_cheque = self.cheque_no + 1
      end
    end
  end
  
  def nom_employe
    return self.employe.nom + ', ' + self.employe.prenom
  end
  
  def prenom_nom
    return self.employe.prenom + ' ' + self.employe.nom
  end
  
  def total
    self.net + self.remb_depense
  end
  
  def montant_alphabetique
    chiffres = %w(zero un deux trois quatre cinq six sept huit neuf)
    n = self.total
    res = ''
    while n > 0 do
      unit = n.modulo(10)
      res = ' - ' + res unless res.empty?
      res = chiffres[unit] + res
      n = n.div(10)
    end
    res = '*** ' + res + sprintf(' *** et %02d/100', (self.total * 100).modulo(100))
  end
  
  def heures
    self.feuille ? self.feuille.totalHeures : 0
  end
  
  # Obtenir un numero de cheque si pas deja
  def setChequeNo
    employeur = Employeur.instance
    if employeur.prochain_no_cheque > 0
      self.cheque_no = employeur.prochain_no_cheque
      employeur.prochain_no_cheque = employeur.prochain_no_cheque + 1
      employeur.save!
    end
  end
  
  def periode_debut
    self.periode.debut    
  end

  def periode_end
    periode_debut + Employeur.instance.semaines_par_paie * 7
  end
  
  def periode_fin
    periode_end - 1
  end
  
  def tot_deductions
    return self.rrq + self.ae + self.rqap + self.impot_fed + self.impot_prov
  end
  
  def employe_heures_upto
    return self.employe.heures_range(
      Date.civil(self.periode_debut.year, 1, 1), self.periode_end)
  end

  #
  # Fonctions pour extraire des totaux pour une plage de date
  #
  
  # Faire la somme d'une "colonne" de tous les fiche Paie entre (debut, fin)
  # inclusivement. Instances de Date.
  def self.total_colonne(debut, fin, colonne)
    sum = Paie.count_by_sql(
      sprintf("select sum(%s) from paies as t inner join periodes as p on t.periode_id = p.id where (debut >= '%s' and debut <= '%s')",
        colonne, debut.to_s(:db), fin.to_s(:db)))
    sum.nil? ? 0 : sum
  end
end
