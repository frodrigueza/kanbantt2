# Servicio para importar de xml
class Importer

	# def initialize(path, upload_path)
	# 	@upload_path = upload_path
	# 	xml = File.open(path)
	# 	p "Loading xml..."
	# 	@hash = Hash.from_xml(xml)
	# 	p "Finished loading xml!"
	# end

	def initialize(file_upload, user_id)

		@user = User.find(user_id[:user_id])

		# El path donde se va a guardar el archivo
		Dir.mkdir 'public/uploads' unless File.directory?('public/uploads')
		upload_path = Rails.root.join('public', 'uploads', file_upload.original_filename)

		# Si ya existe un archivo con el mismo nombre se crea con un número (i)
		if File.exist? upload_path.to_s
			i=1
			path = upload_path.to_s.insert(-4, "(#{i.to_s})")
			while File.exist? path do
				i = i+1
			end
			name = file_upload.original_filename.insert(-5, "(#{i.to_s})")
			upload_path = Rails.root.join('public', 'uploads', name)
		end

		# Se crea el archivo en el path
		File.open(upload_path, 'wb') do |file|
			file.write(file_upload.read)
		end

		@upload_path = upload_path.to_s
		xml = File.open(file_upload.path())
		p "Loading xml..."
		@hash = Hash.from_xml(xml)
		p "Finished loading xml!"
	end

	def import(project)
		hash = @hash["Project"]["Tasks"]["Task"]
		# a.a

		Task.transaction do
			# CREAMOS EL PROYECTO
			project.name = hash[0]["Name"]
			project.expected_start_date = hash[0]["Start"].to_date
			project.expected_end_date = hash[0]["Finish"].to_date
			project.xml_file = @upload_path
			project.owner_id = @user.id
			project.sneaky_save

			Assignment.create(user_id: @user.id, project_id: project.id, role: 1)

			out_line = 1
			last = nil

			# Se recorren las tareas
			# out_line_level = 1 es el proyecto
			(1..(hash.size-1)).each do |i|
				h = hash[i]
				cost = h["Cost"].to_f > 0 ? h["Cost"].to_f : 0




				# CREAMOS LA TASK
				t = Task.new
				t.name = h["Name"]
				t.expected_start_date = (h["Start"]).to_date
				t.expected_end_date = (h["Finish"]).to_date
				t.project_id = project.id
				t.resources_cost = cost
				t.save

				# REPORTES DE LA TASK
				if(h["Type"].to_i == 0)
					# si tiene avance y es de ultimo nivel se reporta
					if(h["PercentComplete"].to_i> 0)
						r = Report.new(task_id:t.id, progress: h["PercentComplete"].to_i, created_at: Time.now)

						r.save
					end
				end



				# PADRES E HIJAS
				# si es primer hijo
				if h["OutlineLevel"].to_i == 1

				# si es un hijo de la anterior
				elsif h["OutlineLevel"].to_i > out_line
					t.parent_id = last.id



				# si es un hermana de la anterior
				elsif h["OutlineLevel"].to_i == out_line
					t.parent_id = last.parent_id


				# si es tia de la anterior
				else
					ascendence = out_line - h["OutlineLevel"].to_i
					node = last.parent

					ascendence.times do
						node = node.parent 
					end
					t.parent_id = node.id
				end

				# guardamos
				t.sneaky_save
				out_line = h["OutlineLevel"].to_i
				last = t
			end
			#calcula progresos
			project.manage_indicators
			return project
		end
	end
end