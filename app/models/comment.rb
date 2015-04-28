class Comment < ActiveRecord::Base
	#Pertenece a una tarea
	belongs_to :task

	# pertenece a un usuario ya que no solo el dueño de la tarea puede dejar comentarios en esta, tambien el 
	# admin del proyecto y el super admin
	belongs_to :user

end
