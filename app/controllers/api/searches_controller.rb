class Api::SearchesController < ApplicationController
  before_action :validate_search_params

  def index
    search_params = {
      city: params[:location_id],
      check_in: params[:check_in],
      check_out: params[:check_out],
      adults: params[:quests][:adults].to_i,
      children: params[:quests][:children].to_i
    }

    results = External::Hotels.search(search_params)
    render json: results
  rescue External::Hotels::Error => e
    render json: { error: { code: 'SEARCH_ERROR', message: e.message } }, status: :bad_gateway
  end

  private

  def validate_search_params
    errors = []

    %i[location_id check_in check_out guests].each do |param|
      errors << "#{param} is required" if params[param].blank?
    end

    errors << 'adults must be at least 1' if params.dig(:quests, :adults).to_i < 1

    # Validate dates
    if params[:check_in].present? && params[:check_out].present?
      begin
        check_in = Date.parse(params[:check_in])
        check_out = Date.parse(params[:check_out])
        
        if check_in >= check_out
          errors << 'check_out must be after check_in'
        elsif (check_out - check_in).to_i > 60
          errors << 'stay duration cannot exceed 60 days'
        end
      rescue Date::Error
        errors << 'invalid date format (use YYYY-MM-DD)'
      end
    end

    if errors.any?
      render json: { error: { code: 'VALIDATION_ERROR', message: errors.join(', ') } }, status: :unprocessable_entity
    end
  end
end

