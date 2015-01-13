class Assignment < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  validates_uniqueness_of :user_id, scope: :project_id


  def f_role
  	if role == 1
  		'Administrador'
  	elsif role == 2
  		'Last Planner'
  	end
  end
end
