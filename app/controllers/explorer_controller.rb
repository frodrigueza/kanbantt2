class ExplorerController < ApplicationController
  def tree_view
  	@projects = current_user.projects
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
