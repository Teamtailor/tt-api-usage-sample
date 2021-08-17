class TeamtailorApiClient
  BASE_URL = 'https://api.teamtailor.com/v1/'.freeze

  def initialize(resource, api_key)
    @resource = resource
    @api_key = api_key
  end

  def fetch(page = 1, size = 10)
    params = { page: { number: page, size: size } }
    response = Faraday.get(resource_url, params, headers)
    JSON.parse(response.body)
  end

  def fetch_all_data
    data = []
    response = fetch
    data += response['data']
    total_pages = response.dig('meta', 'page-count')
    (2..total_pages).each do |page_number|
      response_data = response_data(page_number)
      data += response_data unless response_data
    end
    data
  end

  def response_data(page = 1, size = 10)
    response = fetch(page, size)
    response['data']
  end

  private

  attr_reader :resource, :api_key

  def headers
    { Authorization: "Token token=#{api_key}", 'X-Api-Version': '20210218' }
  end

  def resource_url
    @resource_url ||= BASE_URL + resource
  end
end
