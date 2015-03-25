class Task < ActiveRecord::Base
  require 'gcm'
  require 'json'
  require 'thread'
  	#Tiene versionamiento de datos
	has_paper_trail
	@@sending = false

	#Una tarea puede tener muchos hijos, y cada tarea tiene a lo más un padre.
	has_many :children, foreign_key: 'parent_id', class_name: 'Task', dependent: :destroy
	belongs_to :parent, class_name: 'Task'

	#Una tarea tiene muchos reportes
	has_many :reports, dependent: :destroy

	has_many :indicators, dependent: :destroy

	#Una tarea tiene un dueño
	belongs_to :user

	#Una tarea pertenece a un proyecto
	belongs_to :project

	#Tiene muchos comentarios
	has_many :comments

	# after_commit :call_update, on: [:create, :update, :destroy]

	scope :done, -> { where(progress: 100) }
	scope :not_done, -> { where.not(progress: 100) }
	scope :by_level, -> (order: :desc){ order(level: order) }
	scope :in_level, -> (level) { where(level: level) }
	scope :by_id, -> (order: :asc){order(mpp_uid: order)}

	#que el nombre este presente al crear/editar la tarea
	validates :name, presence: true

	#validacion para que la fecha de fin sea posterior a la de comienzo
	validates_presence_of :expected_start_date
	validates_presence_of :expected_end_date
	validate :end_date_is_after_start_date
	# validate :resources_positive

	# # Si cambio el responsable, que toda la descendencia quede con ese responsable	
	after_save :check_parent_user
	after_save :update_project_after_save
	after_destroy :update_project_after_destroy

	#Verificamos que la fecha de termino sea menor a la fecha de inicio
	def end_date_is_after_start_date
		if expected_end_date < expected_start_date
			errors.add(:expected_end_date, "La fecha de término debe ser posterior a la de inicio")
		end 
  	end

  	def resources_positive
  		if project.resources_type != 0  && self.resources_cost_from_children <= 0
  			errors.add(:resources_cost, "La tarea " + name + " debe tener un costo de recursos mayor a 0")
  			return false
  		end
  	end


  


	




# METODOS HELPERS ############################################################################





	# calcula el costo de la tarea sumando el de las tareas hijas 
	# o entrega su propio resources cost si no tiene hijas
	def resources_total_cost
		if has_children?
			children.includes(:children).map(&:resources_total_cost).inject(:+)
		else
			resources_cost
		end
	end

	# metodo para setear el nivel de profundidad de la tarea
	def set_level
	   self.level = parent ? parent.level + 1 : 1
	end

	def enterprise
		project.enterprise
	end

	def f_dates
		array = []
		array << expected_start_date.strftime("%d %b")
		array << expected_end_date.strftime("%d %b")
	end
	
	#Verificamos si se cambiaron los plazos de la tarea
	def date_changed?
		expected_start_date_changed? or expected_end_date_changed? or duration_changed?
	end

	# devuelve la tarea padre o el proyecto si es que es tarea de primer nivel
	def project_or_parent
		parent || project
	end

	# progreso como float
	def progress_f
		progress.to_f/100
	end

	# fecha esperada de inicio como string
	def expected_start_date_s
		if expected_start_date 
			expected_start_date.strftime("%d-%m-%Y")
		end
	end

	# fecha esperada de fin como string
	def expected_end_date_s
		if expected_end_date 
			expected_end_date.strftime("%d-%m-%Y")
		end
	end
	
	def class_urgente
		if self.urgent
			return 'urgente'
		else
			return 'no_urgente'
		end
	end

	# boolean si la tarea esta atrasada
	def delayed
		if progress < expected_progress
			return true
		end

		return false
	end

	# si se encuentra comprometida o no
	def commited
		if !has_children? && progress != 100 && state == 1 && user_id
			true
		else
			false
		end
	end

	def expected_start_date_from_children
		if !has_children?
			return expected_start_date.to_date
		else
			children.min_by { |x| x.expected_start_date_from_children }.expected_start_date_from_children
		end
	end

	def expected_end_date_from_children
		if !has_children?
			return expected_end_date.to_date
		else
			children.max_by { |x| x.expected_end_date_from_children }.expected_end_date_from_children
		end
	end

	def f_duration_or_cost
		r_type = project.resources_type
		case r_type
		when 0
			duration.to_s + ' d'
		when 1
			resources_cost_from_children.round(1).to_s + ' usd'	
		when 2
			resources_cost_from_children.round(1).to_s + ' UF'	
		when 3
			resources_cost_from_children.round(1).to_s + ' hh'	
		end
	end

	def f_state
		if !self.user
			'Tarea no asignada'
		else
			if state == 0
				'Asignada'
			elsif state == 1
				'Comprometida'
			elsif state == 2
				'Finalizada'
			end
		end
	end

	def toggle_urgent
		if self.urgent
			self.urgent = false
		else
			self.urgent = true
		end		
		self.sneaky_save
	end

	# boolean si la tarea está terminada o no
	def done
		self.progress == 100
	end

	# boolean si la tarea se ecuentra en progreso
	def in_progress
		self.info_progress[0] > 0 && self.info_progress[0] < 100
	end

	# días que quedan desde hoy hasta la fecha esperada de término
	def remaining_to_end
		(self.expected_end_date_from_children.to_date - Date.today).to_i
	end

	def remaining_to_start
		(self.expected_start_date_from_children.to_date - Date.today).to_i
	end

	def ancestry
		array = []
		array[0] = self
		i = 0
		while array[i].parent
			array << array[i].parent
			i += 1
		end

		array.reverse
	end

	def f_ancestry
		string = ''
		if parent_id
			ancestry.each do |t|
				string += t.name + ' >> '
			end
		else
			return 'Tarea de primer nivel, no posee ascendencia'
		end

		string
	end


	def refresh
		# si tiene progreso 100, la movemos a la columna de finalizada
		if progress == 100
			self.state = 2

		# si es que esta marcada como finalizada y su progreso no es de 100%, la movemos a la columna de inactivos
		elsif state == 2
			self.state = 0
		end

		self.sneaky_save
	end

	# dias de desfase, utilizado en la vista de assignments
	def gap_days
		if progress == 100
			# primer reporte en el que se reporto un 100% de avance
			(expected_end_date.to_date - reports.where(progress:100).first.created_at.to_date).to_i
		elsif expected_progress == 100
			# dias de atraso ya que la task no esta terminada
			(expected_end_date.to_date - Date.today).to_i.to_s
		else
			''
		end
	end

	# entrega las tareas hermanas de una tarea (las hijas de su padre)
	def brothers
		aux = []
		self.parent.children.each do |c|
			aux << c unless c == self
		end
		aux
	end

	def has_children?
		children.size > 0
	end

	# primera fecha de inicio de hijos
	def children_start
		project_or_parent.children.sort_by{|t| t[:expected_start_date]}.first.try(:expected_start_date)
	end

	# ultima fecha de termino de hijos
	def children_end
		project_or_parent.children.sort_by{|t| t[:expected_end_date]}.last.try(:expected_end_date)
	end

	#último reporte antes de la fecha solicitada
	def last_report_before(date)
		array = []
		reports.each do |r|
			if r.created_at.to_date <= date
				array << r
			end
		end

		array = array.sort_by { |r| r.created_at}
		array.last
	end

	# días desde que la tarea empezó hasta la fecha
	# si no ha empezado es 0 y si ya terminó es la duración de la tarea
	def wdays_from_start(date)
		if date < expected_start_date
			0
		elsif date > expected_end_date
			duration
		else
			(expected_start_date.to_date..date.to_date-1).select {|d| (1..5).include?(d.wday) }.size
		end
	end

	# metodo que devuelve el nombre de la tarea padre
	def parent_name
		if self.parent
			parent.try(:name)
		else
			self.project.name
		end
	end

	# metodo que devuelve el nombre del usuario responsable
	def user_name
		user.try(:name)
	end


	# devuelve un arreglo con todas las tareas que estan debajo
	def tasks_below_count
		count = 0
		children.each do |c|
			count += 1
			count += c.tasks_below_count
		end
		count
	end

	#Si una tarea padre tiene un responsable, toda su descendencia tiene el mismo user.
	def check_parent_user
		if user_id_changed? and has_children?
			children.each do |c|
				c.user_id = user.id
				# usamos sneaky save (sin callbacks) para que no se recalculen los avances del proyecto
				c.sneaky_save
				c.check_parent_user
			end
		end
	end


	def destroy_without_callback
		reports.map(&:delete)
		comments.map(&:delete)
		children.each do |c|
			c.destroy_without_callback
		end
		self.delete
	end





	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 







	# Duracion calculada dinamicamente segun hijos contando todos los dias (incluidos fines de semana)
	def duration
		if !has_children?
			(expected_start_date.to_date..expected_end_date.to_date).to_a.uniq.size
		else
			aux = 0
			children.each do |c|
				aux += c.duration
			end

			return aux 
		end

	end

	# Duracion calculada dinamicamente segun hijos contando solo dias hábiles
	def wdays_duration
		if !has_children?
			(expected_start_date.to_date..expected_end_date.to_date).select {|d| (1..5).include?(d.wday) }.size
		else
			aux = 0
			children.each do |c|
				aux += c.wdays_duration
			end

			return aux 
		end

	end

	# reportes que contienen recursos
	def resources_reports
		array = []
		reports.each do |r|
			if r.resources != 0
				array << r
			end
		end

		array
	end


	# Progreso real hoy
	def progress
		if project.resources_type == 0
			real_progress_function(Date.today, false)
		else
			real_progress_function(Date.today, true)
		end
	end

	# Progrso estimado hoy
	def expected_progress
		if project.resources_type == 0
			expected_progress_function(Date.today, false)
		else
			expected_progress_function(Date.today, true)
		end
	end

	# Formula que entrega el avance real segun fecha y unidad especificada
	# date = datetime
	# in_resources = boolean	
	def real_progress_function(date, in_resources)
		if !has_children?
			if reports.count > 0
				if last_report_before(date)
					last_report_before(date).progress
				else
					0
				end
			else
				0
			end
		else
			total_children_value = 0
			total_children_value_extolled = 0

			if !in_resources
				children.each do |c|
					total_children_value += c.duration
					total_children_value_extolled += c.real_progress_function(date, in_resources) * c.duration
				end
			else
				children.each do |c|
					total_children_value += c.resources_cost_from_children
					total_children_value_extolled += c.real_progress_function(date, in_resources) * c.resources_cost_from_children
				end
			end

			return (total_children_value_extolled/total_children_value).to_f.round(1)
		end
	end

	# Formula que entrega el avance esperado segun fecha y unidad especificada
	# date = datetime
	# in_resources = boolean
	def expected_progress_function(date, in_resources)
		if !has_children?
			if date >= expected_end_date_from_children
				100
			elsif  wdays_duration > 0
				((wdays_from_start(date).to_f/wdays_duration)*100).round(1)
			else
				0
			end
		else
			total_children_value = 0
			total_children_value_extolled = 0

			# si lo piden en tiempo
			if !in_resources
				children.each do |c|
					aux_duration = c.wdays_duration
					total_children_value += aux_duration
					total_children_value_extolled += c.expected_progress_function(date, in_resources) * aux_duration
				end
			# si lo piden en recursos
			else
				children.each do |c|
					aux_resources_cost = c.resources_cost_from_children
					total_children_value += aux_resources_cost
					total_children_value_extolled += c.expected_progress_function(date, in_resources) * aux_resources_cost
				end
			end


			return (total_children_value_extolled/total_children_value).to_f.round(1)
		end
	end


	# Costo calculado dinamicamente segun los hijos
	def resources_cost_from_children
		if !has_children?
			return self.resources_cost
		else
			suma = 0
			children.each do |c|
				suma += c.resources_cost_from_children
			end

			return suma 
		end
	end

	# reporte rapido
	def fast_report(user_id)
		if progress != 100
			# Creamos un reporte hecho por el usuario de la sesion
			Report.create(progress: 100, user_id: user_id, task_id: self.id, created_at: Time.now)
		end
		self.state = 2
		self.sneaky_save
	end

	def f_parent_id
		if parent_id
			parent_id
		else
			-1
		end
	end

	# metodo que determina la posicion de la task en la columna de kanban
	def kanban_order
		progress.to_i - expected_progress.to_i
	end

	# preparamos los parametros para cuando el metodo es llamado desde el controlador (menos acoplamiento)
	def pre_move_dates(params)
		year = params['new_date(1i)'.to_sym].to_i
		month = params['new_date(2i)'.to_sym].to_i
		day = params['new_date(3i)'.to_sym].to_i

		new_start_date = Date.new(year, month, day).to_date
		old_start_date = self.expected_start_date_from_children.to_date
		days_diff = (new_start_date - old_start_date).to_i
		self.move_dates(days_diff)
	end

	# metodo que desplaza una tarea y todas sus hijas en el mismo numero de dias
	def move_dates(number_of_days)
		if has_children?
			last_level_tasks_below.each do |t|
				t.expected_start_date += number_of_days.days
				t.expected_end_date += number_of_days.days
				t.sneaky_save
			end
		else
			self.expected_start_date += number_of_days.days
			self.expected_end_date += number_of_days.days
			self.sneaky_save
		end

		# luego de haber movido las tasks, recalculamos los indicadores
		project.manage_indicators
	end

	# arreglo con todas las tasks de ultimo nivel bajo esta
	def last_level_tasks_below
		array = []
		children.each do |t|
			if !t.has_children?
				array << t
			else
				(array << t.last_level_tasks_below).flatten!.uniq
			end
		end

		array
	end

	def update_project_after_save
		# solo cuando se actualizan ciertos atributos modificamos los indicadores
		if resources_cost_changed? || expected_start_date_changed? || expected_end_date_changed?
			project.manage_indicators
		end
	end


	def update_project_after_destroy
		if !@destroyed_by_association
			# luego de eliminar, modificamos todos los indicadores
			project.manage_indicators
		end
	end

	# def dates
	# 	start_date = expected_start_date_from_children
	# 	# si la fecha de entrega ya paso pero el proyecto todavia no se termina,
	# 	# debemos mostrar el avance real hasta la fecha y seguir el esperado en 100
	# 	if Date.today > expected_end_date_from_children && progress < 100
	# 	  end_date = Date.today
	# 	else
	# 	  end_date = expected_end_date_from_children
	# 	end

	# 	array = []
	# 	number_of_days = end_date - start_date

	# 	# si el proyecto dura menos de 1 mes, lo hacemos por dia
	# 	if number_of_days <= 30
	# 	  if number_of_days > 0
	# 	    for i in 0..number_of_days
	# 	      new_date = start_date + i
	# 	      array << new_date
	# 	    end
	# 	  end

	# 	# sino lo hacemos semanalmente e inlcuimos los dias que se hicieron reportes
	# 	else
	# 	  # Hacemos que la primera fecha despues de la fecha de inicio sea el lunes siguiente
	# 	  first_date = nil
	# 	  case start_date.wday
	# 	    when 1
	# 	      first_date = start_date + 7
	# 	    when 2
	# 	      first_date = start_date + 6
	# 	    when 3
	# 	      first_date = start_date + 5
	# 	    when 4
	# 	      first_date = start_date + 4
	# 	    when 5
	# 	      first_date = start_date + 3
	# 	    when 6
	# 	      first_date = start_date + 2 
	# 	    when 0
	# 	      first_date = start_date + 1
	# 	  end

	# 	  still_in_range = true
	# 	  # mientras nos encontremos en el rango de fechas de proyecto, agregaremos todos los lunes de este rango
	# 	  while still_in_range
	# 	    array << first_date
	# 	    first_date = first_date + 7
	# 	    if first_date > end_date
	# 	      still_in_range = false
	# 	    end
	# 	  end

	# 	  # Agregamos la fecha del ultimo reporte porque puede ser que este se haya hecho depues del ultimo lunes que paso
	# 	  # y es necesario contabilizarlo. Y en el caso que fue justo un lunes, no importa ya que se eliminan los repetidos.
	# 	  if reports.last
	# 	    array << reports.last.created_at.to_date
	# 	  end
	# 	end

	# 	array << start_date
	# 	array << end_date

	# 	array.uniq.sort
	# end

	# def progress_indicators
	# 	array = []
	# 	dates.each do |d|
	# 		i = {}
	# 		i[:real_progress] = real_progress_function(false, date)
	# 	end
	# end
end
