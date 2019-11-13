class CreatePerformances < ActiveRecord::Migration[6.0]
  def change
    create_table :performances do |t|
      t.datetime :start

      t.timestamps
    end
  end
end
