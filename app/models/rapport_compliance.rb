# coding: utf-8
# Produire un rapport qui verifie que les directives sont suivies.
# Nous devons toujours avoir au moins 1 sauveteurs ayant 17 ans.
# On peut generer ce rapport avec la console.
#
class RapportCompliance

  attr_reader :data  # Une Array of [employe_nom, dateTime] 
  
  def initialize
    @data = Array.new
    
    # Obtenir toutes les feuilles de temps les employes de moins de 18 ans
    minDate = Date::today().years_ago(18);
    Feuille.
      joins('inner join employes as empl on employe_id = empl.id').
      where('empl.naissance > ?', minDate.to_s(:db)).each do | f |
      f.heures.each do | hr |
        0.step(hr.duree-1, 60) do | minsFromStart |
          dateTime = hr.debut + minsFromStart * 60
          
          # We only care if the guard was not 17 at that time
          ageMin = dateTime.years_ago(17)
          if ageMin.to_date < f.employe.naissance
            # Ok. we need to find another guard that was working with him that was seventeen
            hr2 = Heure.find_by_sql(
               ["select debut from heures inner join feuilles as f on feuille_id = f.id inner join employes as empl on f.employe_id = empl.id 
                   where debut <= :start and debut + interval duree minute >= :fin and empl.naissance < :ageMin limit 1",
               {:start => dateTime.to_s(:db), :fin => (dateTime+3600).to_s(:db), :ageMin => ageMin.to_s(:db)}])
            if !hr2 || hr2.empty?
              # Pas d'autres employes. Enregistrer
              @data << [f.employe.nom_prenom, dateTime]
            end
          end
        end
      end
    end  
  end

end