class ProjectsController < ApplicationController
  load_and_authorize_resource

  before_action :set_project, only: [:show, :edit, :update, :destroy, :stads]

  # GET /projects
  # GET /projects.json
  def index
    @projects = current_user.projects
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @users = @project.users
    # if current_user.super_admin
    #   redirect_to project_second_indicators_path(@project)
    # elsif current_user.enterprise.boss == current_user
    #   redirect_to project_second_indicators_path(@project)
    # else
    #   redirect_to project_kanban_board_path(@project)
    # end
  end

  def second_indicators
    
  end

  # GET /projects/new
  def new
    @project = Project.new(owner_id: current_user.id)
  end

  # GET /projects/1/edit
  def edit
  end


  # POST /projects
  # POST /projects.json

  def create
    @project = Project.new(project_params)
    # a.a

    if params[:project][:xml_file]
      i = Importer.new(params[:project][:xml_file], user_id: current_user.id)
      i.import(@project)
    end

    respond_to do |format|
      if @project.save
        format.html { redirect_to explorer_tree_view_path }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # vista de confirmacion
  def delete
    @project = Project.find(params[:project_id])    
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    #cuando se borra un proyecto borrar también el archivo xml
    if @project.xml_file and File.exist?(@project.xml_file)
      File.delete(@project.xml_file)
    end
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  # metodo asociado a la vista de arbol de un proyecto y sus tareas
  def tree_view
    @project = Project.find(params[:project_id])

    respond_to do |format|
      format.html
      format.js
    end

  end

  # Metodo asociado a la vista de la carta gantt de un proyecto
  def gantt
    @project = Project.find(params[:project_id])
  end

  # Metodo asociado a la vista de indicadores de un proyecto
  def indicators
    @project = Project.find(params[:project_id])
  end

  def stads
    @users = @project.users
    @kanban = @project.kanban
  end

  def root
    # administrador
    if current_user.role_in_project(@project) == 1
      redirect_to explorer_tree_view_path(project_id: @project.id)
      
    # empleado
    elsif current_user.role_in_project(@project) == 2
      redirect_to kanban_board_index_path(project_id: @project.id)
    end
  end

  def export
    project = Project.find(params[:project_id])
    e = Exporter.new(project)
    begin
      hash = e.export
      path = "#{project.name.gsub(' ', '_').camelize}.xml"
      f = File.open(path, "w")
      p "Writing file.."
      f.write(hash["Project"].to_xml(:root => 'Project', skip_types: true))
      send_file(f, disposition:'attachment')
      f.close
      p "File ready!"
    rescue
      flash[:alert] = "No se pudo exportar."
      redirect_to project_path(project)
    end
  end

  def add_tree_view_column
    # tarea de la cual se desplegaran sus hijos en una nueva columna del arbol
    @task = Task.find(params[:parent_id])
    @project = Project.find(params[:project_id])
    respond_to do |format|
      format.js
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    if params[:id]
      @project = Project.find(params[:id])
    elsif params[:project_id]
      @project = Project.find(params[:project_id])
    end
  end

  def check_permissions
    if !current_user.projects.include?(@project)
      redirect_to explorer_tree_view_path
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    params.require(:project).permit(:name, :owner_id, :start_date, :end_date, :expected_start_date, :expected_end_date, :xml_file, :resources_type, :resources_reporting, :enterprise_id)
  end


end
