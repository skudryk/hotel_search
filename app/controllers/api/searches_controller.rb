class Api::SearchesController < ApplicationController
  include Searches::Validations

  before_action :validate_search_params
  
  def index
    search_params = {
      location_id: params[:location_id],
      check_in: params[:check_in],
      check_out: params[:check_out],
      adults: params[:adults].to_i,
      children: params[:children].to_i
    }

    results = BoomNow::Hotels.search(search_params)
    render json: results
  rescue BoomNow::Hotels::Error => e
    render json: { error: { code: 'SEARCH_ERROR', message: e.message } }, status: :bad_gateway
  end


end


