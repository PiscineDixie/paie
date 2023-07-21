# coding: utf-8
# Objet representant un groupe de feuille de temps.
# Cet objet n'est pas sauve dans la base de donnee mais reconstitue a partir des elements de Feuille
# Les feuilles de temps seront eventuellement utilisees pour generer une paie
class FeuilleGroupe
  
  attr_reader :debut  # date de debut de la periode de paye, class Date
  attr_reader :feuilles # objet local pour les feuilles de temps
  
  # Lire les donnees de la db. Pour chaque employe n'ayant pas de record, en ajouter un
  #  - debut: date du debut de la periode de paie
  def initialize(debut)
    @debut = debut
    
    # Allez chercher les feuilles de temps deja existantes
    @feuilles = Feuille.where("periode = ?", debut.to_formatted_s(:db)).to_a
    
    # Ensuite ajouter des feuilles de temps pour les employes
    employes = Employe::employesActif
    employes.each do | empl |
      if Feuille.find_by("employe_id = ? and periode = ?", empl.id, @debut.to_formatted_s(:db)).nil?
        feuille = Feuille.new({:employe_id => empl.id, :periode => @debut})
        @feuilles << feuille
      end
    end
    @feuilles.sort!{ |f1, f2 | f1.nom <=> f2.nom }
  end
  
  # Retourne la date juste apres le dernier jour de la periode
  def fin
    empl = Employeur.instance
    return @debut + 7 * empl.semaines_par_paie
  end
  
  # Retourne le total des heures travailles
  def totalHeures
    total=0
    @feuilles.each { |f| total = total + f.totalHeures }
    total
  end
  
  # Retourner un array de Date avec les dates des debuts de periode
  def self.candidates
    res = Array.new
    empl = Employeur.instance
    start = empl.debut_paie
    while start < empl.fin_paie
      res << start
      start = start + 7 * empl.semaines_par_paie
    end
    return res
  end
  
  def employeLock
    @feuilles.each do |f|
      unless f.empl_locked
        f.empl_locked = true;
        f.save!
      end
    end
  end

  def employeUnlock
    @feuilles.each do |f|
      if f.empl_locked
        f.empl_locked = false;
        f.save!
      end
    end
  end
end
