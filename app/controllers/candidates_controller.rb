class CandidatesController < ResourcesController
  def index
    export? ? export : filter
  end

  def filter
    @data = TeamtailorApiClient.new('candidates', filters, api_key).fetch(current_page)
    @next_page = response_page_param('next')
    @prev_page = response_page_param('prev')
    set_max_page
  end

  def export
    all_data = TeamtailorApiClient.new('candidates', filters, api_key).fetch_all_data
    csv = CsvGenerator.new(all_data).run
    send_data csv, type: 'text/csv', filename: "candidates_export_#{Time.current}.csv"
  end
end
