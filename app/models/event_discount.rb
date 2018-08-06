class EventDiscount < ApplicationRecord
  include Swagger::Blocks
  validates_numericality_of :early_bird_registration, :late_registration, :on_site_registration, :allow_nil => true
  validates_numericality_of  :early_bird_players, :late_players, :on_site_players, :only_integer => true, :allow_nil => true


  swagger_schema :EventDiscount do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with discount"
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event id associated with discount"
    end
    property :early_bird_registration do
      key :type, :number
      key :format, :float
      key :description, "Early bird registration discount associated with discount"
    end
    property :early_bird_players do
      key :type, :integer
      key :format, :int64
      key :description, "Early bird players quantity associated with discount"
    end
    property :early_bird_date_start do
      key :type, :string
      key :format, :date
      key :description, "Early bird date start associated with discount\nFormat: YYYY-MM-DD"
    end

    property :early_bird_date_end do
      key :type, :string
      key :format, :date
      key :description, "Early bird date end associated with discount\nFormat: YYYY-MM-DD"
    end
    property :late_registration do
      key :type, :number
      key :format, :float
      key :description, "Late registration discount associated with discount"
    end

    property :late_players do
      key :type, :integer
      key :format, :int64
      key :description, "Late players quantity associated with discount"
    end
    property :late_date_start do
      key :type, :string
      key :format, :date
      key :description, "Late date start associated with discount\nFormat: YYYY-MM-DD"
    end

    property :late_date_end do
      key :type, :string
      key :format, :date
      key :description, "Late date end associated with discount\nFormat: YYYY-MM-DD"
    end

    property :on_site_registration do
      key :type, :number
      key :format, :float
      key :description, "On site registration discount associated with discount"
    end
    property :on_site_players do
      key :type, :integer
      key :format, :int64
      key :description, "On site players quantity associated with discount"
    end

    property :late_date_start do
      key :type, :string
      key :format, :date
      key :description, "Late date start associated with discount\nFormat: YYYY-MM-DD"
    end

    property :late_date_end do
      key :type, :string
      key :format, :date
      key :description, "late date end associated with discount\nFormat: YYYY-MM-DD"
    end
  end

  swagger_schema :EventDiscountInput do
    property :early_bird_registration do
      key :type, :number
      key :format, :float
    end
    property :early_bird_players do
      key :type, :integer
      key :format, :int64
    end

    property :early_bird_date_start do
      key :type, :string
      key :format, :date
    end

    property :early_bird_date_end do
      key :type, :string
      key :format, :date
    end


    property :late_registration do
      key :type, :number
      key :format, :float
    end

    property :late_players do
      key :type, :integer
      key :format, :int64
    end

    property :late_date_start do
      key :type, :string
      key :format, :date
    end

    property :late_date_end do
      key :type, :string
      key :format, :date
    end

    property :on_site_registration do
      key :type, :number
      key :format, :float
    end
    property :on_site_players do
      key :type, :integer
      key :format, :int64
    end

    property :on_site_date_start do
      key :type, :string
      key :format, :date
    end

    property :on_site_date_end do
      key :type, :string
      key :format, :date
    end
  end
end
