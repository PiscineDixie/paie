# coding: utf-8
# Objet representant un rapport detaille par heure
#


class MatriceHeures
  
  attr_reader :fg  # FeuilleGroupe
  attr_reader :heures # Array[Heure]
  attr_reader :employe_id # Optionel. Sinon tous les employes
  attr_reader :debut, :fin # des objects Date
  
  @@zoneoffset = -8*3600 
  
  # debut/fin sont des dates
  def initialize(debut, fin, employe = nil)
    @data = Array.new # array< heure, array< hash<act,#heures> > >
    @debut = debut
    @fin = fin
    @employe_id = employe
    populate2()
  end

  # Retourne l'information des heures travailles pour une date et une heure
  def get(heure, date)
    @data.assoc(heure)[1][(date - @debut).to_i] || {}
  end
  
  # Retourne une array avec l'entete pour chaque colonne. Selon la date
  # de la periode.
  def dates
    res = Array.new
    @debut.upto(@fin) { |x| res << x }
    res.pop
    res
  end
  
  # Retourne une array des heures pour lesquelles il y a de l'information
  # Je construit a partir du premier element 
  def heures
    res = Array.new
    @data.each { |x| res << x[0] }
    res
  end
  
  # Retourne le total des heures travaillees pour une date
  def total(date)
    t = 0.0
    @data.each do | hrData |
      jourData = hrData[1][date.yday - @debut.yday];
      unless jourData.nil?
        jourData.each_value { | v | t += v }
      end
    end
    t
  end
  
  private
  
  def populate2
    # Voir les commentaires dans Heure.rb
    debutDb = @debut.to_time.beginning_of_day.getlocal(@@zoneoffset)
    finDb = @fin.to_time.beginning_of_day.getlocal(@@zoneoffset)
    
    if @employe_id.nil?
      recs = Heure.
        where("debut >= :minDateTime and debut < :endDateTime",
          {:minDateTime => debutDb.to_s(:db), :endDateTime => finDb.to_s(:db)})
    else
      recs = Heure.
        joins('inner join feuilles as f on feuille_id = f.id').
        where('employe_id = :empl_id and debut >= :minDateTime and debut < :endDateTime',
          {empl_id: @employe_id, :minDateTime => debutDb.to_s(:db), :endDateTime => finDb.to_s(:db)})
    end
    
    recs.each do | hr |
      hrDebT = hr.debut.getlocal(-4*3600)+4*3600
      hrFinT = hrDebT + hr.duree * 60
      h = hrDebT.at_beginning_of_hour
      while (h < hrFinT) do
        # Get the data for this hour of the day
        @data << [h.hour, []] if @data.assoc(h.hour).nil?
        hrData = @data.assoc(h.hour)
        
        # Get the hash of act -> hr for this hour/day
        hrData[1][h.yday - @debut.yday] = Hash.new(0) if hrData[1][h.yday - @debut.yday].nil?
        dateData = hrData[1][h.yday - @debut.yday]
        
        
        # Add the number of minutes in this hour for this act to existing
        nh = h + 3600
        duree = 1.0
        if hrFinT < nh 
          duree = (3600.0 - (nh - hrFinT).to_i) / 3600.0
        elsif hrDebT > h
          duree = (3600.0 - (hrDebT - h).to_i) / 3600.0
        end
        dateData[hr.activite] += duree
        h = nh
      end
    end
    @data.sort! { |x,y| x[0] <=> y[0] }
  end
  
  
 end
