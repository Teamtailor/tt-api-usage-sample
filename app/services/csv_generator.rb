class CsvGenerator
  def initialize(data)
    @data = data
  end

  def run
    parse_data_attributes
    CSV.generate(headers: true) do |csv|
      csv << data.first.keys unless data.empty?

      data.each do |row|
        csv << row.values
      end
    end
  end

  private

  attr_reader :data

  def parse_data_attributes
    @data.map! { |row| row['attributes'] }
  end
end
