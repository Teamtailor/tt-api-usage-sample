class DashboardsController < ApplicationController
  def index
    @api_key = session[:api_key]
  end
end
