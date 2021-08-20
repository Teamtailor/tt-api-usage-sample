module CandidateLocationsHelper
  def candidate_locations(candidate, included)
    return if included.blank?

    location_ids = candidate.dig('relationships', 'locations', 'data')&.map { |locations_hash| locations_hash['id'] }
    return if location_ids.blank?

    locations = location_ids.map do |location_id|
      included.find { |item| item['type'] == 'locations' and item['id'] == location_id }.dig('attributes', 'city')
    end

    locations.uniq.join (', ')
  end
end
