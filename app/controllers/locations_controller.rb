class LocationsController < ResourcesController
  def index
    locations = TeamtailorApiClient.new('locations', nil, nil, api_key).fetch(1)['data']
    render json: locations
  end
end
