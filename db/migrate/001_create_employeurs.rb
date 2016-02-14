class CreateEmployeurs < ActiveRecord::Migration
  def self.up
    create_table :employeurs do |t|
      t.string :nom
      t.string :adresse1, :adresse2, :adresse3
      t.string :numero_entreprise

      # Date du debut de la premiere periode de paie de l'annee.
      t.date   :debut_paie
      t.date   :fin_paie
      t.integer :semaines_par_paie
      
      # Numero du prochain cheque de paie
      t.integer :prochain_no_cheque
      
      t.timestamps
    end
    
  end

  def self.down
    drop_table :employeurs
  end
end
