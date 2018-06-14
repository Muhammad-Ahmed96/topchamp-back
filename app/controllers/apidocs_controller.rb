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
    key :host, 'ec2-34-215-140-55.us-west-2.compute.amazonaws.com:444'
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
      AttendeeType,
      ApplicationPasswordController,
      ApplicationSessionsController,
      VenueFacilityManagementController,
      VenuesController,
      RolesController,
      ResetTokenController,
      SportsController,
      StatusController,
      EventTypesController,
      SportRegulatorsController,
      AttendeeTypeController,
      UsersController,
      SponsorsController,
      AgendaTypesController,
      GeographyController,
      RegionsController,
      LanguagesController,
      FacilitiesController,
      ApplicationConfirmationsController,
      ApplicationRegistrationsController,
      VisibilityController,
      EventsController,
      BracketsController,
      EliminationFormatsController,
      CategoriesController,
      ScoringOptionsController,
      SkillLevelsController,
      ErrorModel,
      SuccessModel,
      PaginateModel,
      VenueFacilityManagement,
      Venue,
      VenueDay,
      VenuePicture,
      AgendaType,
      Region,
      Sponsor,
      Language,
      EventPaymentInformation,
      EventPaymentMethod,
      EventDiscount,
      EventDiscountGeneral,
      EventDiscountPersonalized,
      EventTax,
      EventRegistrationRule,
      Event,
      Region,
      Category,
      ScoringOption,
      EventRule,
      EventBracketAge,
      EventBracketSkill,
      SportRegulator,
      EliminationFormat,
      EventAgenda,
      self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
