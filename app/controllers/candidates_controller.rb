class CandidatesController < ApplicationController
  def index
    @data = TeamtailorApiClient.new('candidates', api_key).fetch(current_page)
    @next_page = response_page_param('next')
    @prev_page = response_page_param('prev')
  end

  private

  attr_reader :data

  def api_key
    @api_key ||= session[:api_key]
  end

  def current_page
    params.permit(:page)['page'] || 1
  end

  def response_page_param(direction)
    url = data.dig('links', direction)
    return if url.nil?

    uri = URI.parse(url)
    CGI.parse(uri.query)['page[number]'].first
  end
end
