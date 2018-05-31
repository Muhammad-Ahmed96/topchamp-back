module Response
  def json_response(object, status = :ok)
    render json: object, status: status
  end

  def json_response_success(message, success, status = :ok)
    render json: {success: success, message: message}, status: status
  end

  def json_response_error(errors, status = :ok)
    render json: {success: false, errors: errors}, status: status
  end

  def json_response_data(object, status = :ok)
    render json: {data: object}, status: status, adapter: :json
  end

  def json_response_serializer(object, serializer, status = :ok)
    data = ActiveModelSerializers::SerializableResource.new(object, serializer: serializer, adapter: :json, root: :data).to_json
    render json: data, status: status
  end

  def json_response_serializer_collection(object, serializer, status = :ok)
    data = ActiveModelSerializers::SerializableResource.new(object, each_serializer: serializer, adapter: :json, root: :data).to_json
    render json: data, status: status
  end
end