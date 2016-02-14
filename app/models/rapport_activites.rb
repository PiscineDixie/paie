# coding: utf-8
# Classe pour les donnees d'un rapport du nombre d'heures par activites
# C'est un container generique. Les donnees peuvent etre pour une annee,
# une periode de paye, un employe, etc.
#

class RapportActivites
  attr_reader :employe_id # Optionel. Sinon tous les employes
  attr_reader :debut, :fin
  attr_reader :data 
  
  # Debut/fin: Des dates de debut du rapport et de fin
  # Employe: le "id" d'un employe pour lequel on fait le rapport
  def initialize(debut, fin, employe = nil)
    @debut = debut
    @fin = fin
    @employe_id = employe
    
    @data = Array.new # array of array [ code, nom, heures]. 
    
    # Obtenir un hash { code d'activite => # heures }
    codeHrs = Heure.heuresTravaillees(debut.to_time, fin.to_time, employe)
    
    # Convertir le hash en un vecteur avec le code, le nom de l'activite
    # (au lieu du code) et le nombre d'heures
    codeHrs.each do |code, hrs|
      @data << [code, Activite.nom(code), hrs]
    end
    
    # Sort en ordre alphabetique de nom d'activite
    @data.sort!
  end
  
  def total
    sum = 0;
    @data.each { |cds| sum += cds[2] }
    return sum;
  end
  
end