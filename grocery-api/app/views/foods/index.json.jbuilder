json.foods @foods do |food|
  json.name food.name
  json.expiration_date food.duration_seconds.seconds.from_now
end