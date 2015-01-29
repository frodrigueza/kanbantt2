json.array! @tasks do |task|
  json.id task.id
  json.text task.name
  json.start_date task.expected_start_date_from_children
  json.end_date task.expected_end_date_from_children
  json.task_duration task.duration
  json.parent task.parent_id
  json.progress task.progress.to_i
  json.users task.user.try(:name)
  json.open true
end