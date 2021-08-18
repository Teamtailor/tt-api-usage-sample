class ResourcesController < ApplicationController
  private

  attr_reader :data

  def api_key
    @api_key ||= session[:api_key]
  end

  def current_page
    @current_page = params.permit(:page)['page'] || 1
  end

  def export?
    params['commit']&.include? 'Export'
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
