class AddColourIdToTask < ActiveRecord::Migration
  def change
  	add_column :tasks, :colour_id, :integer
  end
end
