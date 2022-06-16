json.extract! reservation, :id, :reference, :user, :flight_nb, :is_business, :created_at, :updated_at
json.url reservation_url(reservation, format: :json)
