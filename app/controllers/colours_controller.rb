class ColoursController < ApplicationController
  before_action :set_colour, only: [:show, :edit, :update, :destroy]
  before_action :check_super_admin

  respond_to :html

  def index
    @colours = Colour.all.sort_by{ |c| c.tasks.count }.reverse
    respond_with(@colours)
  end

  def show
    respond_with(@colour)
  end

  def new
    @colour = Colour.new
    respond_with(@colour)
  end

  def edit
  end

  def create
    @colour = Colour.new(colour_params)
    @colour.save
    redirect_to colours_path
  end

  def update
    @colour.update(colour_params)
    redirect_to colours_path
  end

  def destroy
    @colour.destroy
    redirect_to colours_path
  end

  private
    def set_colour
      @colour = Colour.find(params[:id])
    end

    def check_super_admin
      if !current_user.super_admin
        redirect_to root_path
      end
    end

    def colour_params
      params.require(:colour).permit(:code)
    end
end
