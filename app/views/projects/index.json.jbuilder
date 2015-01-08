json.array!(@projects) do |project|
  json.extract! project, :id, :name, :expected_start_date, :expected_end_date, :progress
  json.url project_url(project, format: :json)
end
