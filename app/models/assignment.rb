class Assignment < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  validates_uniqueness_of :user_id, scope: :project_id
  validate :user_is_not_owner


  def f_role
  	if role == 1
  		'Administrador'
  	elsif role == 2
  		'Last Planner'
  	end
  end

  # VALIDACIONES
  def user_is_not_owner
  	if Project.find(project_id).owner == User.find(user_id)
  		errors.add('Este usuario ya es dueño de ese proyecto, no puede ser asignado a él')
  		return false
  	end
  end
end
