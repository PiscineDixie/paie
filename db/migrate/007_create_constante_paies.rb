class CreateConstantePaies < ActiveRecord::Migration
  def self.up
    create_table :constante_paies do |t|
       
      # Table pour l'impot federal
      t.integer :deductionBaseFed
      t.decimal :impFedI1, :impFedI2, :impFedI3, :precision => 8, :scale => 0, :default => 0
      t.decimal :impFedR1, :impFedR2, :impFedR3, :impFedR4, :precision => 8, :scale => 2, :default => 0
      t.decimal :impFedK1, :impFedK2, :impFedK3, :impFedK4, :precision => 8, :scale => 0, :default => 0
      
      # Table pour l'impot provincial
      t.integer :deductionBaseProv
      t.decimal :impProvI1, :impProvI2, :precision => 8, :scale => 0, :default => 0
      t.decimal :impProvT1, :impProvT2, :impProvT3, :precision => 8, :scale => 2, :default => 0
      t.decimal :impProvK1, :impProvK2, :impProvK3, :precision => 8, :scale => 0, :default => 0
      
      # Table des deductions
      t.decimal :aeTauxEmployeur, :aeTauxEmploye, 
                :rrqTauxEmployeur, :rrqTauxEmploye,
                :rqapTauxEmployeur, :rqapTauxEmploye,
                :fssTauxEmployeur,
                   :precision => 8, :scale => 6, :default => 0
                   
      # Les maximums pour chacune des deductions
      t.decimal :aeMaximumEmploye, :rrqMaximumEmploye, :rqapMaximumEmploye, :precision => 8, :scale => 2, :default => 0
      
      # Gain assurable de l'AE
      t.decimal :aeMaximumGainAssurable, :precision => 8, :scale => 0, :default => 0
      
      # Exemption de base pour RRQ
      t.decimal :rrqExemptionEmploye, :precision => 8, :scale => 2, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :constante_paies
  end
end
