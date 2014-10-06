json.array!(@users) do |user|
  json.extract! user, :id, :name, :remaining_data, :ip, :next_hop, :session_key, :nonce, :timestamp
  json.url user_url(user, format: :json)
end
