class AddIndexToEmployes < ActiveRecord::Migration
  def change
    add_index(:employes, :courriel, unique: true, name: 'employes_unique_courriel')
    add_index(:users, :courriel, unique: true, name: 'users_unique_courriel')
  end
end
