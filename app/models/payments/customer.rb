include AuthorizeNet::API
module Payments
  class Customer
    def self.get(user)
      profile = Payments::Profile.get(user.customer_profile_id)
      if profile.nil?
        profile = Payments::Profile.create(user)
      end
      return profile
    end
  end
end