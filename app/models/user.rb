class User < ActiveRecord::Base
	# pertenece a una empresa
	# belongs_to :enterprise

	# es dueño de maximo una empresa
	# has_one :owned_enterprise, class_name:'Enterprise', foreign_key:'boss_id'

	#relación con proyectos
	has_many :assignments, dependent: :destroy
	has_many :projects, through: :assignments
	has_many :owned_projects, class_name:'Project', foreign_key:'owner_id'
	#puede tener muchas tareas
	has_many :tasks
	has_many :reports
	#tiene una api key, esta key debe eliminarse si el usuario es destruido
	has_many :api_key, dependent: :destroy 

	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
	ROLES = %i[super_admin admin last_planner observer]

	def f_name
		name + ' ' + last_name
	end

	def last_report_in_task(task)
		reports.where(task_id: task.id).last
	end

	def assignment_in_project(project)
		Assignment.where(project_id: project.id, user_id: id).first
	end

	def last_report_in_task_date(task)
		report = last_report_in_task(task)
		if report
			report.created_at
		end
	end

	def delayed_commitments(project)
		array = []
		doing_tasks(project).each do |t|
			if t.delayed
				array << t
			end
		end

		array
	end

	# 0 = dueño
	# 1 = admin
	# 2 = lp
	def role_in_project(project)
		if a = Assignment.where(user_id: id, project_id: project.id).first
			return a.role
		else
			return -1
		end
	end

	def f_role_in_project(project)
		case role_in_project(project)
			when -1 then 'Sin cargo'
			when 1 then 'Administrador'
			when 2 then 'Empleado'
		end
			
	end

	def tasks_by_project(project_id)
		self.tasks.where(project_id: project_id)
	end

	def reports_in_project(project)
		array = []
		reports.each do |r|
			if r.project == project
				array << r
			end
		end

		array
	end


	# Retorna true si el usuario esta asignado a algun proyecto del current user
	def show_user(cuser)
		cuser.projects.each do |cup|
			if self.projects.to_a.empty? && !cuser.lp?
				return true
			else
				self.projects.each do |up|
					if up.id == cup.id
						return true
					end
				end
			end
		end
		return false
	end

	def asignar(cuser)
		if cuser.role == 'super_admin'
			return true
		elsif cuser.lp? or cuser.role == 'observer'
			return false
		else
			if self.role == 'super_admin'
				return false
			else
				return true
			end
		end		
	end

	# Metodo que asigna una imagen a los usuarios.
	def image(n)
		if n < 7
			return 'u'+n.to_s+'.jpg'
		else
			self.image(n-7)
		end
	end

	########################### KANBAN

	def to_do_tasks(project)
		to_do_tasks = (tasks.select { |t| t.project_id == project.id && t.state == 0 && !t.has_children? }).sort_by { |t| t.progress }
	end

	def doing_tasks(project)
		doing_tasks = tasks.select { |t| t.project_id == project.id && t.state == 1 && !t.has_children? }.sort_by { |t| t.progress }
	end

	def done_tasks(project)
		done_tasks = tasks.select { |t| t.project_id == project.id && t.state == 2 && !t.has_children? }.sort_by { |t| t.progress }
	end

	######################## FIN KANBAN

	# PERMISOS
	def can_edit_task(task)
		if super_admin
			return true
		elsif a = Assignment.where(user_id: id, project_id: task.project.id).first
			if a.role == 1
				return true
			end
		else
			return false
		end
	end

	def can_report_task(task)
		# if super_admin
		# 	true
		# elsif a = Assignment.where(user_id: id, project_id: task.project.id).first
		# 	# El admin puede reportar cualquier tarea
		# 	if a.role == 1
		# 		return true

		# 	# El lastplanner puede reportar solo sus propias tareas
		# 	elsif task.user == self
		# 		return true
		# 	end
		# else
		# 	return false
		# end
		true
	end

	def can_edit_project(project)
		if super_admin
			return true
		elsif a = Assignment.where(user_id: id, project_id: project.id).first
			if a.role == 1
				return true
			end
		else
			return false
		end
	end

end