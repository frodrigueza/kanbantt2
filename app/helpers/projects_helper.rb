module ProjectsHelper

	def project_delta_progress_css(project, in_resources)
		if project.progress_delta(in_resources) < 0
			'bad'
		else
			'great'
		end
	end

	def project_delayed_days_progress_css(project, in_resources)
		if project.delayed_or_advanced_days(in_resources) < 0
			'bad'
		else
			'great'
		end
	end

	def css_project_status_color(project)
		if project.progress < project.expected_progress
			'bad'
		else
			'great'
		end
	end
end
