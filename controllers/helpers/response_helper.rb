# frozen_string_literal: true

module ResponseHelper
  def success_response(response_data)
    { success: true, data: response_data }
  end

  def failure_response(errors)
    { success: false, errors: errors }
  end
end
