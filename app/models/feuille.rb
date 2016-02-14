# coding: utf-8
# Feuille de temps pour une periode de paie
# Peut etre associe a un objet "paie" pour fournir les heures travaillees
#
class Feuille < ActiveRecord::Base
  
  # Ceci est un hash de la forme: { "0"=>"S-15:30-3", "1" => "S-15:30-3, S-20:30-1" }
  # Variable local qui est convertie en "heures" dans la db
  attr_accessor :jourVar
  
#  attr_accessible :employe_id, :periode, :heures
  
  has_many :heures, :dependent => :delete_all
  
  # L'objet 'paie' sera plutot enleve par l'objet 'employe'
  has_one :paie, :dependent => :nullify
  
  belongs_to :employe
  
  # Validations
  validates_uniqueness_of :periode, :scope => 'employe_id'
  validate :validations
  
  def validations
    Feuille::heuresValidations(self, self.heures)
  end
  
  after_create :after_create_f
  def after_create_f
    self.locked = false;
    self.empl_locked = false;
  end
      
  # Convertir la requete avec l'information sous forme de string en un array d'Heure
  def self.getHeures(debut, joursStrs)
    res = Array.new
    joursStrs.each do |idx, jourStr|
      unless jourStr.empty?
        hrs = Feuille::jourStrToHeures(debut + idx.to_i, jourStr)
        res.concat(hrs)
      end
    end
    return res
  end


  # Retourne une array of Hashes d'Heure pour chacun des blocs d'heures de la string d'une journee
  # La date est la date des heures
  def self.jourStrToHeures(date, jStr)
    res = Array.new
    ps = jStr.split(/[,\ ]+/)  # split into periodes
    previousHour = 0;
    return res if ps.empty?
    ps.each do |p|
       # split into an array with activity code, start and length
      activity,startStr,lengthStr = p.split('-')
      activity = activity.nil? ? p : activity.upcase 
      
      # Valider que pas de decimaux dans le debut ou la longueur
      startStr = "0" if startStr.nil? || startStr.include?(".")
      lengthStr = "0" if lengthStr.nil? || lengthStr.include?(".")
      
      # Convertir le debut et la duree de l'activite.
      begin
        startDate = DateTime.parse(date.to_s(:db) + ' ' + startStr+':00')
      rescue ArgumentError
        startDate = DateTime.parse(date.to_s(:db) + ' 0:00')
      end
      
      lengthMinutes = 0
      begin
        lengthDate = DateTime.parse(lengthStr+':00')
        lengthMinutes = lengthDate.hour * 60 + lengthDate.min
      rescue ArgumentError
      end
      
      res << Heure.new({:activite => activity, :debut => startDate, :duree => lengthMinutes})
    end
    return res
  end
  
  
  # Calculer une array de string ou chaque string est la sommes des heures de la journee
  def calcJours
    # L'array de string pour chacun des blocs d'heures
    res = Hash.new("")
    (0...(Employeur.instance.semaines_par_paie * 7)).each { |i| res[i.to_s] = "" }
    hs = self.heures.order(:debut)
    hs.each do |h|
      s = h.activite + '-' + h.debut.strftime('%H:%M') +'-' + h.duree.div(60).to_s + ':' + sprintf("%02d, ",h.duree.modulo(60))
      d = h.debut.to_date - self.periode
      res[d.to_i.to_s] << s
    end
    res.each { |j| j.slice!(-2..-1) unless j.empty? }  # remove trailing ", "
    res
  end
  
  
  # Retourner l'array de strings equivalente à toutes les heures de la feuille
  def jours
    # Recalcule si la premiere fois
    @jourVar = self.calcJours if @jourVar.nil?
    return @jourVar
  end
        
      
  # Helper function to check that the array of Heure passes all validations
  def self.heuresValidations(model, hrs)
    ok = true
    hrs.each do | h |
      h.valid? if h.errors.empty?
      h.errors.each do | attr, msg |
        model.errors[:base] << msg;
        ok = false;
      end
    end
    
    # Verifier que les heures ne se chevauchent pas
    invHr = Feuille::testHeureOverlap(hrs)
    unless invHr.nil?
     model.errors[:base] << "Heure #{invHr.to_s} chevauche l'heure précédente";
     ok = false
    end
    return ok
  end
  
  
  # Valider qu'il n'y a pas d'overlap entre les heures
  # L'input est une array de Heure
  # Retourne nil ou une heure qui est invalide
  def self.testHeureOverlap(hrs)
    hrsS = hrs.sort { |a, b| a.debut != b.debut ? a.debut <=> b.debut : a.duree <=> b.duree }
    fin = 0
    hrsS.each do |h|
      t = h.debut.to_time.to_i
      return h if t < fin
      fin = t + h.duree * 60
    end
    return nil
  end
  
  
  
  # Retourne le total en heures pour la feuille de temps
  def totalHeures
    return totalMinutes / 60.0
  end
  
  def totalMinutes
    return 0 if self.heures.nil?
    tot = self.heures.sum(:duree)  # duree est en minutes
    tot.nil? ? 0 : tot
  end
  
  def nom
    return self.employe.nom_prenom
  end
  
  # Debut de la periode de paie (une Date)
  def debut
    return self.periode
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
