json.array!(@users) do |user|
  json.extract! user, :id, :name, :last_access, :ip, :next_hop
  json.url user_url(user, format: :json)
end
