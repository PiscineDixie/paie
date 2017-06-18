class ModifyConstantePrecisions < ActiveRecord::Migration
  def change
    change_column :constante_paies, :impFedR1, :decimal, precision: 8, scale: 6
    change_column :constante_paies, :impFedR2, :decimal, precision: 8, scale: 6
    change_column :constante_paies, :impFedR3, :decimal, precision: 8, scale: 6
    change_column :constante_paies, :impFedR4, :decimal, precision: 8, scale: 6
  end
end
