class CreatePeriodes < ActiveRecord::Migration
  def self.up
    create_table :periodes do |t|
      t.date :debut

      t.timestamps
    end
  end

  def self.down
    drop_table :periodes
  end
end
