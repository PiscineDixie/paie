class AddLockToPeriodes < ActiveRecord::Migration
  def change
    add_column :periodes, :locked, :boolean, default: false
  end
end
