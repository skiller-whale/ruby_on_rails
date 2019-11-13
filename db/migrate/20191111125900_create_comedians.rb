class CreateComedians < ActiveRecord::Migration[6.0]
  def change
    create_table :comedians do |t|
      t.string :name
      t.integer :funniness_rating

      t.timestamps
    end
  end
end
