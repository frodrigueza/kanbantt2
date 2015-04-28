class CreateColours < ActiveRecord::Migration
  def change
    create_table :colours do |t|
      t.string :code

      t.timestamps
    end
  end
end
