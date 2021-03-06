class CreateProjectProgress < ActiveRecord::Migration
  def change
    create_table :project_progresses do |t|
      t.date :date, index: true
      t.float :expected
      t.float :real
      t.belongs_to :project, index: true
    end
  end
end
