class ApplicationRegistrationsController < ::DeviseTokenAuth::RegistrationsController

  def sign_up_params
    params.permit(*params_for_resource(:sign_up))
  end
end
