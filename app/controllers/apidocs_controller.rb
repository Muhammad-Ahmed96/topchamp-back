class ApidocsController < ApplicationController
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '1.0.0'
      key :title, 'Top Champ'
      key :description, 'Top Champ API'
    end
    tag do
      key :name, 'Top Champ'
      key :description, 'Top Champ operations'
      externalDocs do
        key :description, 'Find more info here'
        key :url, 'https://swagger.io'
      end
    end
    key :host, 'ec2-34-215-140-55.us-west-2.compute.amazonaws.com'
    key :basePath, '/api'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
      User,
      Sport,
      ContactInformation,
      ShippingAddress,
      BillingAddress,
      AssociationInformation,
      MedicalInformation,
      EventType,
      ApplicationSessionsController,
      RolesController,
      ResetTokenController,
      SportsController,
      #EventTypesController,
      UsersController,
      ErrorModel,
      SuccessModel,
      PaginateModel,
      self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
