class KanbanBoardController < ApplicationController

  def index
    if @project
      hash = current_user.kanban(@project)

      @to_do_tasks = hash[:to_do_tasks]
      @doing_tasks = hash[:doing_tasks]
      @done_tasks = hash[:done_tasks]
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
