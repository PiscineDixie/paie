class CreateFeuilles < ActiveRecord::Migration
  def self.up
    create_table :feuilles do |t|
      t.references :employe
      
      # Début de la période de paie correspondante
      t.date :periode
      
      # Indique que la feuille ne peut plus etre modifie puisque deja utilise pour la paie
      t.boolean :locked, :default => false
      
      t.timestamps
    end
    add_index :feuilles, [:employe_id, :periode], :unique => true, :name => 'par_employe_periode'
  end

  def self.down
    remove_index :feuilles, :name => :par_employe_periode
    drop_table :feuilles
  end
end
