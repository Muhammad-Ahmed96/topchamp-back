class EventDiscount < ApplicationRecord
  include Swagger::Blocks
  validates_numericality_of :early_bird_registration, :late_registration, :on_site_registration
  validates_numericality_of  :early_bird_players, :late_players, :on_site_players, :only_integer => true


  swagger_schema :EventDiscount do
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
    end
    property :early_bird_registration do
      key :type, :float
    end
    property :early_bird_players do
      key :type, :int64
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
      key :type, :float
    end

    property :late_players do
      key :type, :int64
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
      key :type, :float
    end
    property :on_site_players do
      key :type, :int64
    end

    property :late_date_start do
      key :type, :string
      key :format, :date
    end

    property :late_date_end do
      key :type, :string
      key :format, :date
    end
  end

  swagger_schema :EventDiscountInput do
    property :early_bird_registration do
      key :type, :float
    end
    property :early_bird_players do
      key :type, :int64
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
      key :type, :float
    end

    property :late_players do
      key :type, :int64
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
      key :type, :float
    end
    property :on_site_players do
      key :type, :int64
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
