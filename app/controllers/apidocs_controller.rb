class ApidocsController < ApplicationController
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, "1.0.0"
      key :title, "Top Champ"
      key :description, "Top Champ API"
    end
    tag do
      key :name, "Top Champ"
      key :description, "Top Champ operations"
    end
    key :host, "topchampdev.tk"
    key :schemes, ["https"]
    key :basePath, "/api"
    key :consumes, ["application/json"]
    key :produces, ["application/json"]
    tag do
      key :name, 'events'
      key :description, 'events operations'
    end

    tag do
      key :name, 'users'
      key :description, 'Users operations'
    end
    tag do
      key :name, 'players'
      key :description, 'Players operations'
    end
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
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
      InvitationsController,
      InvitationStatusController,
      VisibilityController,
      EventsController,
      BracketsController,
      EliminationFormatsController,
      CategoriesController,
      ScoringOptionsController,
      SkillLevelsController,
      EventEnrollsController,
      EventRegistrationRulesController,
      EventSchedulersController,
      EventDiscountsController,
      EventContestCategoriesController,
      TournamentsController,
      ParticipantsController,
      PlayersController,
      PlayerPartnerController,
      BusinessCategoriesController,
      PartnersController,
      Payments::CreditCardsController,
      Payments::CheckOutController,
      Payments::RefundsController,
      WaitListController,
      ScoresController,
      EventFeesController,
      CertifyScoreController,
      UserEventReminderController,
      DevicesController,
      EventBracketsController,
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
      EventContest,
      EventContestCategory,
      Event,
      Region,
      Category,
      ScoringOption,
      EventRule,
      SportRegulator,
      EliminationFormat,
      Invitation,
      Participant,
      Player,
      BusinessCategory,
      PlayerBracket,
      EventBracket,
      Payments::PaymentProfile,
      Payments::CreditCard,
      User,
      Sport,
      ContactInformation,
      ShippingAddress,
      BillingAddress,
      AssociationInformation,
      MedicalInformation,
      EventType,
      AttendeeType,
      EventSchedule,
      Team,
      Match,
      Round,
      Tournament,
      Score,
      WaitList,
      EventFee,
      EventPersonalizedDiscount,
      CertifiedScore,
      Device,
      self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
