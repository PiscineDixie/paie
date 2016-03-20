# coding: utf-8
# Classe pour les donnees permanente et annuelles d'un employe
#
class Employe < ActiveRecord::Base
    
  # Le ownership des feuilles et des paies est a l'employe.
  has_many :feuilles, :dependent => :destroy
  has_many :paies, :dependent => :destroy
  
  Etats = ['actif', 'inactif']
  
  validates_presence_of :nom, :prenom, :nas, :naissance, :etat, :salaire_horaire
  validates_numericality_of :nas, :salaire_horaire
  validates_uniqueness_of :nas
  
  def password=(pass)
    salt = [Array.new(6){rand(256).chr}.join].pack('m').chomp
    self.password_salt, self.password_hash = salt, Digest::SHA256.hexdigest(pass + salt)
    return true
  end
  
  def self.authenticate(courriel, password)
    empl = Employe.find_by('courriel = ?', courriel)
    if empl.nil? || Digest::SHA256.hexdigest(password+empl.password_salt) != empl.password_hash
      return nil
    end
    empl
  end
  
  # Retourne 'true' si l'employe est exempte du regime de retraite
  # debut est une Date. Correspond au premier jour d'une periode de paie.
  def exempte_rrq(debut)
    # Est-ce que la derniere journee de la periode de paie est dans le mois suivant
    # le mois de l'anniversaire de l'employe de ses 18 ans. Si oui, exempte
    self.naissance.beginning_of_month.next_month.years_since(18) > debut
  end
  
  # Calculer pour le T4 si l'employe etait exempte.
  def exempte_rrq_t4(annee = Date.today.year)
    return rrq_salaire_annuel(annee) == 0
  end
  
  # Method pour retourner les feuilles pour l'employe pour une periode
  def feuilles_range(debut, fin)
    Feuille.
       where("employe_id = :id and periode >= :debut and periode <= :fin", 
        { :id => self.id, :debut => debut.to_s(:db), :fin => fin.to_s(:db)}).
       order(:periode)
  end
  
  # Methode pour preparer une query pour les paie
  def paies_range_query(debut, fin)
    Paie.joins('inner join periodes on periodes.id = paies.periode_id').
          where("employe_id = :empl_id and debut >= :minDate and debut <= :endDate", 
            {:empl_id => self.id, :minDate => debut.to_s(:db), :endDate => fin.to_s(:db)})
  end
  
  # Method pour faire la somme d'une colonne pour un intervalle
  # Arguments de type Date
  def paies_range(debut, fin, colonne)
    paies_range_query(debut, fin).sum(colonne)
  end
  
  # Methodes pour les donnees totaux d'une annee en particulier
  # Premierement une fonction pour trouver toutes les paies d'un employe pour une
  # periode
  # annee: un entier avec l'annee (e.g., 2008)
  def paies_annuel(annee, colonne)
    return paies_range(Date.civil(annee, 1, 1), Date.civil(annee, 12, 30), colonne)
  end
  
  # Nombre d'heures travailles pour une plage de temps. Fin est un jour plus tard
  # debut, fin: Date
  def heures_range(debut, fin)
    sum = Heure.
      joins('inner join feuilles on feuilles.id = heures.feuille_id').
      where("employe_id = :empl_id and debut >= :minDate and debut < :endDate",
        {:empl_id => self.id, :minDate => debut.to_s(:db), :endDate => fin.to_s(:db)}).
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
  
  def rrq_salaire_annuel(annee = Date.today.year)
    paies_range_query(Date.civil(annee, 1, 1), Date.civil(annee, 12, 30)).sum(:brut)
  end
  
  def rqap_annuel(annee = Date.today.year)
    paies_annuel(annee, :rqap)
  end
 
  def self.employesActif
    return Employe.where(etat: 'actif').order("nom, prenom")
  end
  
  def self.call
    return Employe.order("nom, prenom")
  end
  
  def nom_prenom
    return self.nom + ", " + self.prenom
  end
  
  def NOM_prenom
    return self.nom.upcase + ", " + self.prenom
  end
  
  def actif?
    return self.etat == 'actif'
  end

end
