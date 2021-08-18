class CandidatesController < ResourcesController
  def index
    @data = TeamtailorApiClient.new('candidates', filters, api_key).fetch(current_page)
    @next_page = response_page_param('next')
    @prev_page = response_page_param('prev')
    set_max_page
  end
end
