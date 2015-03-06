class ExplorerController < ApplicationController
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
end
