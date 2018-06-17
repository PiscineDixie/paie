# coding: utf-8
# Classe pour une periode d'heures travaillees pour une activite
# Champs:
#  debut: heure de debut (class DateTime). Interpeter comme l'heure locale
#  duree: nombre de minutes (int)
#  activite: code de l'activite durant cette periode (string)
#  feuille_id: lien vers la feuille de l'employe
#
# Il y a une erreur en quelque part et les heures dans la database ne sont
# pas en heure locale mais plutot en UTC-8. A l'heure de Montreal, si 12:00,
# dans la database, on retrouve 8:00.
#
# Lorsqu'on relie, on lit l'heure comme si c'etait l'heure locale mais elle
# a le timezone UTC. On change donc le timezone et on ajouter 4hr pour obtenir
# une heure valide.
#
class Heure < ActiveRecord::Base
  
  @@zoneoffset = -8*3600 
  
#  attr_accessible :activite, :debut, :duree
  
  belongs_to :feuille
  
  validates_presence_of :activite, :debut, :duree
  
  validates_each :activite do |model, attr, value|
    if Activite::CodeActivites.has_key?(value.upcase) == false
      model.errors.add(attr, "Code d'activité invalide pour #{model.to_s}")
    end
  end
  
  validates_each :duree do |model, attr, value|
    if value == 0
      model.errors.add(attr, "Durée invalide pour #{model.to_s}")
    elsif value > 12 * 60
      model.errors.add(attr, "Durée ne peut dépasser 12 heures pour #{model.to_s}")
    elsif value.modulo(15) != 0
      model.errors.add(attr, "Durée doit être un multiple de 15 minutes pour #{model.to_s}")
    end
  end
  
  validates_each :debut do |model, attr, value|
    if (value.hour == 0)
      model.errors.add(attr, "Début de l'activité est invalide pour #{model.to_s}.")
    elsif value.hour < 6
      model.errors.add(attr, "Début de l'activité ne peut pas être avant 6:00 heures pour #{model.to_s}")
    elsif value.hour > 22
      model.errors.add(attr, "Début de l'activité ne peut pas être après 22:00 heures pour #{model.to_s}")
    end
    if value.min.modulo(15) != 0
      model.errors.add(attr, "Début de l'activité doit être un multiple de 15 minutes pour #{model.to_s}")
    end
  end
  
  
  # Retourner un hash { activite => integer } indiquant le nombre de minutes travaillees
  # pour chacune des activites pour la periode donnee (debut, fin]
  # debut et fin sont des objets de type 'Time' (Time.local(...))
  # Si aucun, retourne un hash vide
  def self.minutesTravaillees(debut, fin, employe = nil)
    # Contient le total de minutes pour chaque activite
    res = Hash.new(0)
    
    # Extraire de la db tous les records pour l'interval donnee. Il faut
    # commencer au debut de la journee puisqu'il faut considerer la duree
    debutJour = debut.beginning_of_day.getlocal(@@zoneoffset)
    finT = fin.getlocal(@@zoneoffset)
    if employe.nil?
      recs = Heure.where("debut >= :minDateTime and debut < :endDateTime",
          {:minDateTime => debutJour.to_s(:db), :endDateTime => fin.to_s(:db)})
    else
      recs = Heure.
        joins('inner join feuilles as f on feuille_id = f.id').
        where('employe_id = :empl_id and debut >= :minDateTime and debut < :endDateTime',
          {:empl_id => employe, :minDateTime => debutJour.to_s(:db), :endDateTime => fin.to_s(:db)})
    end
    
    debutT = debut.getlocal(@@zoneoffset)
    recs.each do | hr |
      hrDebT = hr.debut.getlocal(-4*3600)+4*3600
      hrFinT = hrDebT + hr.duree * 60
      duree = 0
      if hrDebT >= debutT && hrFinT < finT then  # comprise dans l'interval
        duree = hrFinT - hrDebT
      elsif hrDebT <= debutT && hrFinT >= finT then # plus grand que l'interval
        duree = finT - debutT
      elsif hrDebT < finT && hrFinT > finT then  # se termine apres l'interval
        duree = finT - hrDebT
      elsif hrDebT < debutT && hrFinT > debutT then # commence avant
        duree = hrFinT - debutT
      end
      res[hr.activite] = res[hr.activite] + duree / 60.0 unless duree == 0
    end
    return res
  end
  
  def self.heuresTravaillees(debut, fin, employe = nil)
    res = Heure::minutesTravaillees(debut, fin, employe)
    res.each do | x, y|
      res.store(x, y/60.0)
    end
    res;
  end
  
  # Retourner une liste des employes qui ont travailles
  # @param debut (Time) pour le debut
  # @param fin (Time) pour la fin
  # @return Array<{}>
  def self.auTravail(debut, fin)
    # Sortir les heures
    debutJour = debut.beginning_of_day.getlocal(@@zoneoffset)
    finT = fin.getlocal(@@zoneoffset)
    hrs = Heure.
      joins("inner join feuilles as f on f.id = feuille_id").
      joins("left join employes as e on e.id = f.employe_id").
      where('debut >= :minDateTime and debut < :endDateTime',
        {:minDateTime => debutJour.to_s(:db), :endDateTime => finT.to_s(:db)}).
      pluck("e.prenom", "e.nom", "heures.activite", "heures.debut", "heures.duree")
      
    res = hrs.each_with_object([]) do | h, r|
      hDeb = h[3].getlocal(-4*3600)+4*3600
      next if hDeb > fin || hDeb + 60 * h[4] <= debut 
      nom = h[0] + ' ' + h[1]
      hr = {nom: nom, activite: h[2], debut: hDeb, duree: h[4]}
      r << hr
    end
    
    # Sort part activite
    res.sort! { |r1,r2| r1[:activite] <=> r2[:activite] }
  end
  
  def to_s
    s = self.debut.to_date.to_s(:db) + " " + self.activite + "-" + self.debut.strftime("%k:%M").lstrip + '-';
    h = self.duree / 60
    s += h.to_s
    m = self.duree % 60
    s += ":" + m.to_s unless m == 0;
    s
  end
  
  # Vrai si les meme proprietes en oubliant les liens db
  def same?(other)
    self.debut == other.debut and 
    self.duree == other.duree and 
    self.activite == other.activite
  end
end
