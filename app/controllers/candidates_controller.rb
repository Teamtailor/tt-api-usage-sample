class CandidatesController < ApplicationController
  def index
    @data = TeamtailorApiClient.new('candidates', filters, api_key).fetch(current_page)
    @next_page = response_page_param('next')
    @prev_page = response_page_param('prev')
    set_max_page
  end

  private

  attr_reader :data

  def api_key
    @api_key ||= session[:api_key]
  end

  def current_page
    @current_page = params.permit(:page)['page'] || 1
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
    @filter_params = params.permit(:email, :created_at_from, :created_at_to, :connected).to_h
  end
end
