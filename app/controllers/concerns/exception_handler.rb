module ExceptionHandler
  # provides the more graceful `included` method
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response_error([e.message], :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response_error(e.record.errors, :unprocessable_entity)
    end
    rescue_from Pundit::NotAuthorizedError do |e|
      json_response_error([e.message], :unauthorized)
    end

    rescue_from Pundit::NotAuthorizedError do |e|
      policy_name = e.policy.class.to_s.underscore
      message = t"pundit.#{policy_name}.#{e.query}"
      json_response_error([message], :unauthorized)
    end
  end
end