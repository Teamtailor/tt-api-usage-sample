class TeamtailorApiClient
  BASE_URL = 'https://api.teamtailor.com/v1/'.freeze
  CONCURRENT_BATCH_SIZE = 10

  def initialize(resource, filters, api_key)
    @resource = resource
    @api_key = api_key
    @filters = filters || {}
  end

  def fetch(page = 1, size = 30)
    response = request(page, size).run
    JSON.parse(response.body)
  end

  def fetch_all_data
    data = []
    response = JSON.parse(request.run.body)
    data += response['data']
    total_pages = response.dig('meta', 'page-count').to_i
    (2..total_pages).each_slice(CONCURRENT_BATCH_SIZE) do |pages_batch|
      requests = concurrent_requests(pages_batch)
      response_data = requests.map { |request| JSON.parse(request.response.body)['data'] }.compact.flatten
      data += response_data if response_data.present?
    end
    data
  end

  def request(page = 1, size = 30)
    params = { page: { number: page, size: size } }.merge(filters)
    Typhoeus::Request.new(resource_url, params: params, headers: headers)
  end

  def concurrent_requests(pages_batch)
    hydra = Typhoeus::Hydra.new
    requests = pages_batch.map do |page_number|
      request = request(page_number)
      hydra.queue(request)
      request
    end
    hydra.run
    requests
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
