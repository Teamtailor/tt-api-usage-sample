class TeamtailorApiClient
  BASE_URL = 'https://api.teamtailor.com/v1/'.freeze

  def initialize(resource, filters, api_key)
    @resource = resource
    @api_key = api_key
    @filters = filters || {}
  end

  def fetch(page = 1, size = 30)
    params = { page: { number: page, size: size } }.merge(filters)
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
      data += response_data if response_data.present?
    end
    data
  end

  def response_data(page = 1, size = 30)
    response = fetch(page, size)
    response['data']
  end

  private

  attr_reader :resource, :api_key, :filters

  def headers
    { Authorization: "Token token=#{api_key}", 'X-Api-Version': '20210218' }
  end

  def resource_url
    @resource_url ||= BASE_URL + resource
  end
end
