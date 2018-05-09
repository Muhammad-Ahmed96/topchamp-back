class ApplicationPasswordController < ::DeviseTokenAuth::PasswordsController
  # this is where users arrive after visiting the password reset confirmation link
  def edit
    # if a user is not found, return nil
    @resource = with_reset_password_token(resource_params[:reset_password_token])

    if @resource && @resource.reset_password_period_valid?
      client_id, token = @resource.create_token

      # ensure that user is confirmed
      @resource.skip_confirmation! if confirmable_enabled? && !@resource.confirmed_at

      # allow user to change password once without current_password
      @resource.allow_password_change = true if recoverable_enabled?

      @resource.save!

      yield @resource if block_given?

      redirect_header_options = {reset_password: true, reset_password_token: resource_params[:reset_password_token]}
      redirect_headers = build_redirect_headers(token,
                                                client_id,
                                                redirect_header_options)
      redirect_to(@resource.build_auth_url(params[:redirect_url],
                                           redirect_headers))
    else
      render_edit_error
    end
  end
end