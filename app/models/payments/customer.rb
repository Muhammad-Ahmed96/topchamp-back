include AuthorizeNet::API
module Payments
  class Customer
    def self.get(user)
      profile = Payments::Profile.get(user.customer_profile_id)
      if profile.nil?
        result = Payments::Profile.create(user)
        profile = Payments::Profile.get(result.customerProfileId)
      end
      return profile
    end
  end
end