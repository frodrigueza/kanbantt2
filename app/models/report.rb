class Report < ActiveRecord::Base
	belongs_to :task
	belongs_to :user
	after_destroy :update_project_indicators
	before_save :update_task

	def project
		task.project
	end

	def user_f_name
		if user
			user.f_name
		else
			'Importacion'
		end
	end

	# actualizamos todos los indicadores del proyecto
	def update_project_indicators
		# que se actualicen los indicadores del proyect solo cuando fue eliminado manualmente
		if !@destroyed_by_association
			project.manage_indicators
		end
	end

	# actualizamos solo un indicador del proyecto
	def update_project_indicator
		# que se actualicen los indicadores del proyect solo cuando fue eliminado manualmente
		if !@destroyed_by_association
			project.manage_indicator(self)
		end
	end

	def update_task
		if task_id
			self.task.refresh
		end
	end
end
