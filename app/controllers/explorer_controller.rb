class ExplorerController < ApplicationController
  before_action :check_permissions, only: [:tree_view]


  def tree_view
    @projects = []
    if params[:project_id]
      @projects << Project.find(params[:project_id])
    else
      @projects = current_user.projects
    end
  end

  def add_column
  	if params[:parent_type] == 'project'
  		@parent = Project.find(params[:parent_id])
  	elsif params[:parent_type] == 'task'
  		@parent = Task.find(params[:parent_id])
  	end

  	respond_to do |format|
      format.js
    end
  end

  def check_permissions
    if params[:project_id] && !current_user.super_admin
      # si el proyecto no pertenece a este usuario, se redirecciona al explorer/tree_view. Excepto para los super_admins
      if !current_user.projects.include?(Project.find(params[:project_id]))
        redirect_to explorer_tree_view_path
      end
    end
  end

end
