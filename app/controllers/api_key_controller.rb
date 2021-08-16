class ApiKeyController < ApplicationController
  def submit
    session[:api_key] = api_key
    redirect_to '/'
  end

  def reset
    session[:api_key] = nil
    redirect_to '/'
  end

  private

  def api_key
    params.permit(:api_key)[:api_key]
  end
end
