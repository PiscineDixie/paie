# Convertir l'heure dans db en UTC
class FixHoursOffset < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      alter table heures drop index par_feuille_debut;
    SQL

    execute <<-SQL
      update heures set debut = debut + INTERVAL 4 HOUR;
    SQL
    
    execute <<-SQL
      alter table heures add unique par_feuille_debut (feuille_id, debut);
    SQL
end
  
  def down
    execute <<-SQL
      alter table heures drop index par_feuille_debut;
    SQL

    execute <<-SQL
      update heures set debut = debut - INTERVAL 4 HOUR;
    SQL
    
    execute <<-SQL
      alter table heures add unique par_feuille_debut (feuille_id, debut);
    SQL
  end
end
