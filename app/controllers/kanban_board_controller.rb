class KanbanBoardController < ApplicationController

  def index
    if @project
      @to_do_tasks = current_user.to_do_tasks(@project)
      @doing_tasks = current_user.doing_tasks(@project)
      @done_tasks = current_user.done_tasks(@project)
    else
      redirect_to current_user
    end
  end

  def update_item_partial
    @task = Task.find(params[:task_id])

    respond_to do |format|
      format.js
    end
  end
end
