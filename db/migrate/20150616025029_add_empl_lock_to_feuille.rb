class AddEmplLockToFeuille < ActiveRecord::Migration
  def change
    add_column :feuilles, :empl_locked, :boolean, default: false
  end
end
