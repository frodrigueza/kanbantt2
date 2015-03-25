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
			return to_spanish(resp)
		else
			''
		end
	end

	def datepicker_f_date(date)
		date.strftime("%m/%d/%Y")
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

	def css_less_is_better(i)
		if i < 0
			'great'
		elsif i == 0
			''
		else
			'bad'
		end
	end

	def css_more_is_better(i)
		if i < 0
			'bad'
		elsif i == 0
			''
		else
			'great'
		end
	end
end
