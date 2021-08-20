# frozen_string_literal: true

class TeamtailorApiClientRateLimitExceeded < StandardError; end

class TeamtailorApiClientError < StandardError; end

class TeamtailorApiClient
  BASE_URL = 'https://api.teamtailor.com/v1/'.freeze
  CONCURRENT_BATCH_SIZE = 40

  def initialize(resource, filters, includes, api_key)
    @resource = resource
    @api_key = api_key
    @filters = filters || {}
    @includes = includes || {}
  end

  def fetch(page = 1, size = 30)
    begin
      retries ||= 0
      response = request(page, size).run
      JSON.parse(response.body)
    rescue TeamtailorApiClientRateLimitExceeded
      sleep(redis.get('rate-limit-remaining').to_i + 1)
      retry if (retries += 1) < 3
      raise TeamtailorApiClientRateLimitExceeded, ['Rate Limit Exceeded']
    end
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
    params = { page: { number: page, size: size } }.merge(filters, includes)
    allow_request?
    request = Typhoeus::Request.new(resource_url, params: params, headers: headers)
    request.on_complete do |response|
      handle_response(response)
    end
    request
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

  attr_reader :resource, :api_key, :filters, :includes

  def headers
    { Authorization: "Token token=#{api_key}", 'X-Api-Version': '20210218' }
  end

  def handle_response(response)
    response_headers = response.headers.to_h.slice('X-Rate-Limit-Remaining', 'X-Rate-Limit-Reset')
    redis.setex('rate-limit-remaining', response_headers['X-Rate-Limit-Reset'].to_i,
                response_headers['X-Rate-Limit-Remaining'])
    return if response.success?

    errors = JSON.parse(response.body)['errors'].map! { |error| error.slice('title', 'detail').values.join(': ') }
    raise TeamtailorApiClientError, errors
  end

  def redis
    @redis ||= Redis.new
  end

  def resource_url
    @resource_url ||= BASE_URL + resource
  end

  def allow_request?
    rate_limit_remaining = redis.get('rate-limit-remaining') || 1
    raise TeamtailorApiClientRateLimitExceeded unless rate_limit_remaining.to_i.positive?
  end
end
