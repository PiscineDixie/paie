class AddLockToPeriodes < ActiveRecord::Migration[5.0]
  def change
    add_column :periodes, :locked, :boolean, default: false
  end
end
