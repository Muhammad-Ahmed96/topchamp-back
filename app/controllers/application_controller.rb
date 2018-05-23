class ApplicationController < ActionController::API
  include Pundit
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ExceptionHandler
  include Response
  delegate :t, to: I18n
  before_action :repair_nested_params
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name,:email, contact_information: [:cell_phone, :country_code_phone, :alternative_email, :address_line_1, :address_line_2,
                                                                                                             :postal_code, :state, :city,:country_code_work_phone , :work_phone, :emergency_contact_full_name,
                                                                                                             :emergency_contact_country_code_phone, :emergency_contact_phone, :is_receive_text]])
  end

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    redirect_to(request.referrer || root_path)
  end

  def repair_nested_params(obj = params)
    obj.each do |key, value|
      if value.is_a? ActionController::Parameters or value.is_a? Hash
        # If any non-integer keys
        if value.keys.find {|k, _| k =~ /\D/ }
          repair_nested_params(value)
        else
          obj[key] = value.values
          value.values.each {|h| repair_nested_params(h) }
        end
      end
    end
  end
end
