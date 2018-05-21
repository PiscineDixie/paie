class CreatePeriodes < ActiveRecord::Migration[5.0]
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
