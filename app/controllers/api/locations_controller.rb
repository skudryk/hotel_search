class Api::LocationsController < ApplicationController
  before_action :validate_query_param

  def index
    locations = External::Locations.search(params[:q])
    render json: locations
  rescue External::Locations::Error => e
    render json: { error: { code: 'LOCATIONS_ERROR', message: e.message } }, status: :bad_gateway
  end

  private

  def validate_query_param
    return if params[:q].present? && params[:q].length >= 2

    render json: { error: { code: 'INVALID_QUERY', message: 'Query must be at least 2 characters long' } }, status: :unprocessable_entity
  end
end

