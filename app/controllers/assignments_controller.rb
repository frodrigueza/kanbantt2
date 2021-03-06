class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @assignments = Assignment.all.sort_by {|a| [a.project_id, a.role, a.user.f_role_in_project(a.project)]}
    respond_with(@assignments)
  end

  def show
    @user = @assignment.user
    @project = @assignment.project
    respond_with(@assignment)
  end

  def new
    @assignment = Assignment.new(project_id: params[:project_id], user_id: params[:user_id])
    if @project
      @available_users = @project.available_users
    end
    respond_with(@assignment)
  end

  def edit
  end

  def create
    @assignment = Assignment.new(assignment_params)
    @assignment.save
    
    redirect_to request.referer
  end

  def update
    @assignment.update(assignment_params)
    redirect_to request.referer
  end

  def destroy
    @assignment.destroy
    respond_with(@assignment)
  end

  private
    def set_assignment
      @assignment = Assignment.find(params[:id])
      if params[:project_id]  
        @project = Project.find(params[:project_id])
      end
    end

    def assignment_params
      params.require(:assignment).permit(:project_id, :user_id, :role)
    end
end
