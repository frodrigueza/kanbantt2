class Indicator < ActiveRecord::Base
	belongs_to :project
	belongs_to :task

	# Calculamos el progreso esperado y real del proyecto y lo almacenamos en un indicador
	def set_progresses(date)
		self.real_days_progress = project.real_progress_function(date, false)
		self.expected_days_progress = project.expected_progress_function(date, false)

		if self.project.resources_type != 0
			self.real_resources_progress = project.real_progress_function(date, true)
			self.expected_resources_progress = project.expected_progress_function(date, true)
		end
	end
end
