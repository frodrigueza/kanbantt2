class TasksController < ApplicationController
  load_and_authorize_resource
  before_action :set_task, only: [:show, :edit, :update, :destroy, :toggle_urgent, :move_dates, :change_colour]

  # GET /tasks
  # GET /tasks.json
  def index
    @project = Project.find(params[:project_id])
    @tasks = @project.tasks
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    @report = Report.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /tasks/new
  def new
    # Creamos una tarea que tendra un proyecto, su padre y la fecha 
    @task = Task.new(project_id: params[:project_id])

    # hay veces que se crean tareas de primer nivel por lo que no tienen parent_id, solo corresponden al proyecto.
    if params[:parent_id]
      parent = Task.find(params[:parent_id])
      @task.expected_start_date = parent.expected_start_date_from_children
      @task.expected_end_date = parent.expected_end_date_from_children
      @task.parent_id = params[:parent_id]
      @task.user_id = Task.find(params[:parent_id]).user_id
    else
      @task.expected_start_date = [@project.expected_start_date, Date.today].max
      @task.expected_end_date = [@project.expected_end_date, Date.tomorrow].max
    end

    if @project
      if @project.resources_type == 1
        @task.resources_cost = 100
      elsif @project.resources_type == 2
        @task.resources_cost = 1
      elsif @project.resources_type == 3
        @task.resources_cost = 8
      end
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /tasks/1/edit
  def edit

  end

  # POST /tasks
  def create
    @task = Task.new(task_params)
    @project = @task.project
    respond_to do |format|
      if @task.save
        format.html { redirect_to request.referer }
        format.json { render :show, status: :created, location: @task }
        format.js { render 'explorer/add_task.js.erb' }
      else
        format.html { redirect_to request.referer }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  def update
    @project = @task.project

    respond_to do |format|
      if @task.update(task_params)
        @task.update_project_after_save
        format.html { redirect_to :back }
        format.js { render 'explorer/_update_tree_view.js.erb' }
      else
        format.html { redirect_to request.referer }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def list
    @comments = Comment.find(:all)
  end

  # DELETE /tasks/1
  def destroy
    project = @task.project
    @task.destroy
    project.manage_indicators


    respond_to do |format|
      format.html { redirect_to request.referer }
    end
  end

  def change_colour
    @task.colour = Colour.find(params[:colour_id])
    @task.save

    respond_to do |format|
      format.js
    end
  end

  def delete_confirmation
    @task = Task.find(params[:task_id])
    respond_to do |format|
      format.html
    end
  end

  def fast_report
    @task = Task.find(params[:task_id])
    @task.fast_report(params[:user_id])
    @task.project.manage_indicator(@task.reports.last)

    @project = @task.project

    respond_to do |format|
      format.js { render 'explorer/_update_tree_view.js.erb'}
    end
  end

  def toggle_urgent
    @task.toggle_urgent

    respond_to do |format|
      format.js 
    end
  end

  def move_dates
    @task.pre_move_dates(params)

    respond_to do |format|
      format.html { redirect_to request.referer } 
      format.js 
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_task
    if params[:id]
      @task = Task.find(params[:id])
      @project = @task.project

    # cuando es llamada desde otro controlador
    elsif params[:task_id]
      @task = Task.find(params[:task_id])  
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def task_params
    params.require(:task).permit(:name, :expected_start_date, :expected_end_date,
                                 :start_date, :end_date, :parent_id, :level, :man_hours, :progress,
                                 :description, :duration, :deleted, :project_id, :user_id, :resources_cost, :resources, :state)
  end
end
