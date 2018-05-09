module Response
  def json_response(object, status = :ok)
    render json: object, status: status
  end

  def json_response_success(message, success, status = :ok)
    render json: {success: success, message: message}, status: status
  end

  def json_response_data(object, status = :ok)
    render json: {data: object}, status: status
  end
end