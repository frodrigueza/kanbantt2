json.array!(@indicators) do |indicator|
  json.extract! indicator, :id, :date, :real_days_progress, :expected_days_progress, :real_resources_progress, :expected_resources_progress, :real_used_resources, :expected_used_resources
  json.url indicator_url(indicator, format: :json)
end
