json.array!(@colours) do |colour|
  json.extract! colour, :id, :code
  json.url colour_url(colour, format: :json)
end
