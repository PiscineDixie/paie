class CreateHeures < ActiveRecord::Migration
  def self.up
    create_table :heures do |t|
      t.references :feuille, :null => false
      t.string     :activite, :null => false 
      t.datetime   :debut, :null => false
      t.integer    :duree, :null => false   # en minutes

      t.timestamps
    end
    add_index :heures, [:feuille_id, :debut], :unique => true, :name => 'par_feuille_debut'
    add_index :heures, [:debut], :unique => false, :name => 'par_debut'
  end

  def self.down
    remove_index :heures, :name => :par_feuille_debut
    remove_index :heures, :name => :par_debut
    drop_table :heures
  end
end
