class AddEmplLockToFeuille < ActiveRecord::Migration[5.0]
  def change
    add_column :feuilles, :empl_locked, :boolean, default: false
  end
end
