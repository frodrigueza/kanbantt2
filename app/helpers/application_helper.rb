module ApplicationHelper

	# devuelve una clase que se usa en tree view
	# esta clase se aplicará a todas las columnas menos la primera para hacer un fadeIn en Jquery.
	def column_class(parent)
		if parent.class.name == "Task"
			return 'task_column'
		else
			return 'project_column'
		end
	end

	def f_date(date)
		if date
			resp = date.strftime("%d %b %Y")
			to_spanish(resp)
		else
			''
		end
	end

	def f_short_date(date)
		if date
			resp = date.strftime("%d %b")
			return to_spanish(resp)
		else
			''
		end
	end

	def to_spanish(date)
		date.sub! 'Jan', 'Ene'
		date.sub! 'Apr', 'Abr'
		date.sub! 'Aug', 'Ago'
		date.sub! 'Dec', 'Dic'

		return date
	end
end
