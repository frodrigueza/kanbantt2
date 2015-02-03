class UsersController < ApplicationController
  load_and_authorize_resource

  #manda los proyectos y el usuario que se quiere asignar a proyectos a la vista assign
  def assign
    @projects = Project.all
    @user = User.find(params[:id])
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all
    # if @project
    #   @users = @project.users
    # elsif @enterprise
    #   @users = @enterprise.users
    # end
  end

  def new
    @user = User.new()
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end



  def create
    @user = User.new(user_params)
    
    # @user.name = @user.name.camelize
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path }
        format.json { render :show, status: :created, location: '/users' }
      else
        format.html { render 'new' } ## Specify the format in which you are rendering "new" page
        format.json { render json: @user.errors }
      end
    end
  end

  def show
    @users = User.all
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    if @user.present?
      @user.destroy

      respond_to do |format|
        format.html { redirect_to :back }
        format.json { head :no_content }
      end
    end
  end

  def update

    # required for settings form to submit when password is left blank
    if user_params[:password].blank?
      params[:user].delete(:password)
    end
    @user = User.find(params[:id])
    #Creo un nuevo hash para guardar el nombre con mayuscula
    new_user_params = user_params
    new_user_params[:name] = user_params[:name].camelize
    respond_to do |format|
      if @user.update(new_user_params)

        #para que no se salga de la cuenta cuando se edita la propia contraseña
        #sign_in(super_admin, :bypass => true)
        format.html { redirect_to :back }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end

  end

  def root_router
    case current_user.projects.size
      when 0
        redirect_to projects_path
      when 1
        redirect_to project_root_path(current_user.projects.first)
      else
        redirect_to projects_path
    end
  end

  def user_params
    params.require(:user).permit(:name, :last_name, :email, :password, :password_confirmation)
  end

  private
  def assign_project(project_id)
    if project_id
    @user.projects << Project.find(project_id)
    end
  end


end