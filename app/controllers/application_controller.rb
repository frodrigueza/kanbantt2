class ApplicationController < ActionController::Base

  # para todo los controladores, se definen los objetos segun los params (DRY)
  before_action :set_objects
  helper_method :check_super_admin

  #maneja la excepcion de cuando un usuario no tiene permiso a cierta accion
  rescue_from CanCan::AccessDenied do |exception|
    #se redicrecciona a root
    #quizas deberia redireccionar desde donde se hizo el request
    redirect_to root_url
  end

  def set_objects
    # PROJECTO
    if params[:project_id]
      @project = Project.find(params[:project_id])
    end

    # USUARIO
    if params[:user_id]
      @user = User.find(params[:user_id])
    end
  end

  def check_super_admin
    if !current_user.super_admin
      redirect_to root_path
    end
  end


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #Esto permite que mediante la API se puedan  hacer updates y creates
  protect_from_forgery with: :null_session,
      if:
        Proc.new { |c| c.request.format =~ %r{application/json} }

        #force the user to redirect to the login page if the user was not logged in
        before_action :authenticate_user!

      end
