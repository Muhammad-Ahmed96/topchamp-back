class ApplicationController < ActionController::API
  include Pundit
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ExceptionHandler
  include Response
  delegate :t, to: I18n
  before_action :repair_nested_params
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :set_current_user


  def set_current_user
    Current.user = current_user
    yield
  ensure
    # to address the thread variable leak issues in Puma/Thin webserver
    Current.user = nil
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name,:email])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :birthdate,:mobile])
  end

  def blacklisted_redirect_url?
    DeviseTokenAuth.redirect_whitelist && !DeviseTokenAuth::Url.whitelisted?(@redirect_url)
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

  def transactions_filter
    ActiveRecord::Base.transaction do
      yield
    end
  end
end
