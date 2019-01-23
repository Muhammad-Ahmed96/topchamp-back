class ProcessingFeesController < ApplicationController
  def index
    json_response_serializer_collection( ProcessingFee.all, ProcessingFeeSerializer)
  end
end
