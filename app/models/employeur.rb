# coding: utf-8
# Classe pour les donnees d'un employeur
#
class Employeur < ApplicationRecord
  # Les champs pour un employeur:
  #  nom, adresse1,2,3, numero_entreprise
  #  debut_paie
  
#  attr_accessible :nom, :adresse1, :adresse2, :adresse3, :numero_entreprise
#  attr_accessible :debut_paie, :fin_paie, :semaines_par_paie, :prochain_no_cheque

  validates_presence_of :nom, :adresse1, :adresse2, :debut_paie, :numero_entreprise
  validates_numericality_of :semaines_par_paie
  
  def self.instance
    return Employeur.take
  end
  
  def cheques?
    return self.prochain_no_cheque > 0
  end
  
  def set_prochain_no_cheque(no)
    if no < self.prochain_no_cheque
      self.prochain_no_cheque = no
      self.save!
    end
  end

  # Method pour faire la somme d'une colonne pour un intervalle
  # Arguments de type Date
  def paies_range(debut, fin, colonne)
    Paie.
      joins('inner join periodes on periodes.id = paies.periode_id').
      where("debut >= :minDate and debut <= :endDate", 
        {:minDate => debut.to_formatted_s(:db), :endDate => fin.to_formatted_s(:db)}).
      sum(colonne)
  end
  
  # Methodes pour les donnees totaux d'une annee en particulier
  # Premierement une fonction pour trouver toutes les paies d'un employe pour une
  # periode
  # annee: un entier avec l'annee (e.g., 2008)
  def paies_annuel(annee, colonne)
    return paies_range(Date.civil(annee, 1, 1), Date.civil(annee, 12, 30), colonne)
  end
  
  # Nombre d'heures travailles pour une plage de temps
  # debut, fin: Date
  def heures_range(debut, fin)
    sum = Heure.
      joins('inner join feuilles on feuilles.id = heures.feuille_id').
      where("debut >= :minDate and debut < :endDate",
        {:minDate => debut.to_formatted_s(:db), :endDate => fin.to_formatted_s(:db)}).
      sum(:duree)
    return sum / 60.0
  end
  
  def heures_annuel(annee = Date.today.year)
    return heures_range(Date.civil(annee, 1, 1), Date.civil(annee+1, 1, 1))
  end
  
  def gains_brut_annuel(annee = Date.today.year)
    paies_annuel(annee, :brut)
  end
  
  def gains_net_annuel(annee = Date.today.year)
    paies_annuel(annee, :net)
  end

  def gains_vacances_annuel(annee = Date.today.year)
    paies_annuel(annee, :vacances)
  end
  
  def impot_federal_annuel(annee = Date.today.year)
    paies_annuel(annee, :impot_fed)
  end

  def impot_prov_annuel(annee = Date.today.year)
    paies_annuel(annee, :impot_prov)
  end
  
  def ae_annuel(annee = Date.today.year)
    paies_annuel(annee, :ae)
  end

  def rrq_annuel(annee = Date.today.year)
    paies_annuel(annee, :rrq)
  end
  
  def rqap_annuel(annee = Date.today.year)
    paies_annuel(annee, :rqap)
  end
end
