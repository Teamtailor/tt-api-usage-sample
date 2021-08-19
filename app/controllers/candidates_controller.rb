class CandidatesController < ResourcesController
  private

  def filters_params
    @filter_params = params.permit(:email, :created_at_from, :created_at_to, :connected, :locations).to_h
  end

  def resource_type
    'candidates'
  end
end
