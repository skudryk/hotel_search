module Searches
  module Validations

    private

    def validate_search_params
      errors = []

      %i[location_id check_in check_out adults children].each do |param|
        errors << "#{param} is required" if params[param].blank?
      end

      errors << 'adults must be at least 1' if params[:adults].to_i < 1
      errors << 'location_id must be Integer' if params[:location_id].to_s.to_i < 1

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
end
