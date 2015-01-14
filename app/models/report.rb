class Report < ActiveRecord::Base
	belongs_to :task
	belongs_to :user
	after_save :update_project
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

	def update_project
		# project.manage_indicators
	end

	def update_task
		self.task.refresh
	end
end
