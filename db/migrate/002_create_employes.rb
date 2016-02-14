class CreateEmployes < ActiveRecord::Migration
  def self.up
    create_table :employes do |t|
      t.string  :nom,     :null => false
      t.string  :prenom,  :null => false
      t.string  :adresse1, :adresse2, :adresse3
      t.string  :nas
      t.string  :courriel
      t.boolean :courriel_sommaire, :default => false
      t.date    :naissance, :null => false
      t.string  :etat,    :null => false
      t.decimal :salaire_horaire, :precision => 8, :scale => 2, :null => false
      t.boolean :exempte_impot, :default => false
      t.decimal :exemption_fed, :exemption_prov, :precision => 8, :scale => 2, :null => false, :default => 9600
      
      t.timestamps
    end
  end

  def self.down
    drop_table :employes
  end
end
