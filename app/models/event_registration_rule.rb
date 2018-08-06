class EventRegistrationRule < ApplicationRecord
  include Swagger::Blocks
  #has_secure_password
  validates_inclusion_of :allow_group_registrations, :require_password, :in => [true, false, 0, 1], :allow_nil => true

  swagger_schema :EventRegistrationRule do
    property :id do
      key :type, :integer
      key :format, :int64
      key :description, "Unique identifier associated with registration rule"
    end
    property :event_id do
      key :type, :integer
      key :format, :int64
      key :description, "Event id associated with registration rule"
    end
    property :allow_group_registrations do
      key :type, :boolean
      key :description, "Determine if allow group registrations  associated with registration rule"
    end
    property :partner do
      key :type, :string
      key :description, "Partner associated with registration rule"
    end
    property :require_password do
      key :type, :boolean
      key :description, "Determine if require password associated with registration rule"
    end
    property :password do
      key :type, :string
      key :description, "Password associated with registration rule"
    end
    property :require_director_approval do
      key :type, :boolean
      key :description, "Determine if require director approval associated with registration rule"
    end
    property :allow_players_cancel do
      key :type, :boolean
      key :description, "Determine if allow players cancel associated with registration rule"
    end
    property :use_link_home_page do
      key :type, :boolean
      key :description, "Determine if use link home_page associated with registration rule"
    end
    property :link_homepage do
      key :type, :string
      key :description, "Link homepage associated with registration rule"
    end
    property :use_link_event_website do
      key :type, :boolean
      key :description, "Determine if use link event website associated with registration rule"
    end
    property :link_event_website do
      key :type, :string
      key :description, "Link event website associated with registration rule"
    end

    property :allow_waiver do
      key :type, :boolean
      key :description, "Determine if allow waiver associated with registration rule"
    end

    property :waiver do
      key :type, :string
      key :description, "Waiver associated with registration rule"
    end

    property :allow_wait_list do
      key :type, :boolean
      key :description, "Determine if allow wait list associated with registration rule"
    end
  end

  swagger_schema :EventRegistrationRuleInput do
    property :allow_group_registrations do
      key :type, :boolean
    end
    property :partner do
      key :type, :string
    end
    property :require_password do
      key :type, :boolean
    end

    property :require_password do
      key :type, :boolean
    end
    property :password do
      key :type, :string
    end
    property :require_director_approval do
      key :type, :boolean
    end
    property :allow_players_cancel do
      key :type, :boolean
    end
    property :use_link_home_page do
      key :type, :boolean
    end
    property :link_homepage do
      key :type, :string
    end
    property :use_link_event_website do
      key :type, :boolean
    end
    property :link_event_website do
      key :type, :string
    end
    property :allow_waiver do
      key :type, :boolean
    end

    property :waiver do
      key :type, :string
    end

    property :allow_wait_list do
      key :type, :boolean
    end
  end
end
