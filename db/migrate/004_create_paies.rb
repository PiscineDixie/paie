class CreatePaies < ActiveRecord::Migration
  def self.up
    create_table :paies do |t|
      t.references :employe
      t.references :periode
      t.references :feuille
      t.integer :cheque_no
      
      t.decimal :remb_depense, :precision => 8, :scale => 2, :default => 0
      t.decimal :ajustement_heures, :precision => 8, :scale => 2, :default => 0
      t.decimal :autre_gain_imposable, :precision => 8, :scale => 2, :default => 0
      
      t.decimal :brut, :net, :vacances, :precision => 8, :scale => 2, :default => 0
      
      # Deductions
      t.decimal :ae, :rrq, :rqap, :impot_fed, :impot_prov,
        :precision => 8, :scale => 2, :default => 0

      t.string :note
      
      t.timestamps
    end
    add_index :paies, :periode_id, :unique => false, :name => 'par_periode'
    add_index :paies, [:employe_id, :periode_id], :unique => true, :name => 'par_employe_periode'
  end

  def self.down
    remove_index :paies, :name => :par_periode
    remove_index :paies, :name => :par_employe_periode
    drop_table :paies
  end
end
