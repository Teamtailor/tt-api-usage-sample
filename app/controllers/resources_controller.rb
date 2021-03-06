class ResourcesController < ApplicationController
  def index
    export? ? export : filter
  rescue TeamtailorApiClientRateLimitExceeded, TeamtailorApiClientError => e
    @data = {}
    @max_page = 0
    @errors = JSON.parse(e.message)
    flash.now.alert = 'An error occurred while interacting with Teamtailor API:'
  end

  def filter
    @data = TeamtailorApiClient.new(resource_type, filters, includes, api_key).fetch(current_page)
    @next_page = response_page_param('next')
    @prev_page = response_page_param('prev')
    set_max_page
  end

  def export
    all_data = TeamtailorApiClient.new(resource_type, filters, nil, api_key).fetch_all_data
    csv = CsvGenerator.new(all_data).run
    send_data csv, type: 'text/csv', filename: "#{resource_type}_export_#{Time.current}.csv"
  end

  private

  attr_reader :data, :resource_type

  def api_key
    @api_key ||= session[:api_key]
  end

  def current_page
    @current_page = params.permit(:page)['page'] || 1
  end

  def export?
    params['commit']&.include? 'Export'
  end

  def includes
    {}
  end

  def response_page_param(direction)
    url = data.dig('links', direction)
    return if url.nil?

    uri = URI.parse(url)
    CGI.parse(uri.query)['page[number]'].first
  end

  def set_max_page
    @max_page = data['meta']['page-count']
  end

  def filters
    QueryBuilder.new.run(filters_params) if filters_params.present?
  end

  def filters_params
    @filter_params = params.permit(:email, :created_at_from, :created_at_to, :connected, :location_id).to_h
  end
end
