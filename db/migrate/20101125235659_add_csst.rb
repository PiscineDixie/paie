class AddCsst < ActiveRecord::Migration
  def self.up
    add_column :periodes, :csst_employeur, :decimal, :precision => 8, :scale => 2, :default => 0
    add_column :constante_paies, :csstTauxEmployeur, :decimal, :precision => 8, :scale => 6, :default => 0
  end

  def self.down
    remove_column :periodes, :csst_employeur
    remove_column :constante_paies, :csstTauxEmployeur
  end
end
