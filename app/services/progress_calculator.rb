class ProgressCalculator

	def initialize(project)
		@project = project
	end

	def manage_indicators
		dates = project_dates
		@project.indicators.each do |i|
			# si la fecha del indicador no esta en el arreglo de fechas, es porque fue eliminado el reporte
			# o cambiaron las fechas del proyecto. Lo eliminamos en ese caso
			if !dates.include?(i.date)
				i.destroy
			end
		end

		# Ahora por cada fecha
		dates.each do |date|
			indicator = Indicator.find_or_create_by(project_id: @project.id, date: date)
			indicator.set_progresses(date)
			indicator.save
		end
	end

# 	################ Metodos para cálculos de fechas de proyecto ########################
	def project_dates
		start_date = @project.expected_start_date.to_date
		# si la fecha de entrega ya paso pero el proyecto todavia no se termina,
		# debemos mostrar el avance real hasta la fecha y seguir el esperado en 100
		if Date.today > @project.expected_end_date && @project.progress < 100
			end_date = Date.today
		else
			end_date = @project.expected_end_date.to_date
		end

		array = []
		number_of_days = end_date - start_date

		# si el proyecto dura menos de 1 mes, lo hacemos por dia
		if number_of_days <= 30
			if number_of_days > 0
				for i in 0..number_of_days
					new_date = start_date + i
					array << new_date
				end
			end

		# sino lo hacemos semanalmente e inlcuimos los dias que se hicieron reportes
		else
			# Hacemos que la primera fecha despues de la fecha de inicio sea el lunes siguiente
			first_date = nil
			case start_date.wday
				when 1
					first_date = start_date + 7
				when 2
					first_date = start_date + 6
				when 3
					first_date = start_date + 5
				when 4
					first_date = start_date + 4
				when 5
					first_date = start_date + 3
				when 6
					first_date = start_date	+ 2	
				when 0
					first_date = start_date	+ 1
			end

			still_in_range = true
			# mientras nos encontremos en el rango de fechas de proyecto, agregaremos todos los lunes de este rango
			while still_in_range
				array << first_date
				first_date = first_date + 7
				if first_date > end_date
					still_in_range = false
				end
			end

			# Agregamos la fecha del ultimo reporte porque puede ser que este se haya hecho depues del ultimo lunes que paso
			# y es necesario contabilizarlo. Y en el caso que fue justo un lunes, no importa ya que se eliminan los repetidos.
			if @project.reports.last
				array << @project.reports.last.created_at.to_date
			end
		end

		array << start_date
		array << end_date

		array.uniq.sort
	end
	
end

	