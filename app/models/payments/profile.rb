include AuthorizeNet::API
module Payments
  class Profile < ApplicationRecord
    def self.create(data)
      transaction = Conexion.get
      # Build the payment object
      payment = PaymentType.new(CreditCardType.new)
      payment.creditCard.cardNumber = '4111111111111111'
      payment.creditCard.expirationDate = '2020-05'
      # Build an address object
      billTo = CustomerAddressType.new
      billTo.firstName = data.first_name
      billTo.lastName = data.last_name
      billTo.company = data.association_information.company if data.association_information
      billTo.address = data.contact_information.address_line_1 if data.contact_information
      billTo.city = data.contact_information.city if data.contact_information
      billTo.state = data.contact_information.state if data.contact_information
      billTo.zip = data.contact_information.postal_code if data.contact_information
      billTo.country = data.contact_information.country if data.contact_information
      billTo.phoneNumber = data.contact_information.cell_phone if data.contact_information
      billTo.faxNumber = data.contact_information.cell_phone if data.contact_information

      # Use the previously defined payment and billTo objects to
      # build a payment profile to send with the request
      paymentProfile = CustomerPaymentProfileType.new
      paymentProfile.payment = payment
      paymentProfile.billTo = billTo
      paymentProfile.defaultPaymentProfile = true

      # Build a shipping address  to send with the request
      shippingAddress = CustomerAddressType.new
      shippingAddress.firstName = data.first_name
      shippingAddress.lastName = data.last_name
      shippingAddress.company = data.association_information.company if data.association_information
      shippingAddress.address = data.contact_information.address_line_1 if data.contact_information
      shippingAddress.city = data.contact_information.city if data.contact_information
      shippingAddress.state = data.contact_information.state if data.contact_information
      shippingAddress.zip = data.contact_information.postal_code if data.contact_information
      shippingAddress.country = data.contact_information.country if data.contact_information
      shippingAddress.phoneNumber = data.contact_information.cell_phone if data.contact_information
      shippingAddress.faxNumber = data.contact_information.cell_phone if data.contact_information

      # Build the request object
      request = CreateCustomerProfileRequest.new
      # Build the profile object containing the main information about the customer profile
      request.profile = CustomerProfileType.new
      request.profile.merchantCustomerId = 'top_champ' + data.membership_id
      request.profile.description = data.first_name
      request.profile.email = data.email
      # Add the payment profile and shipping profile defined previously
      request.profile.paymentProfiles = [paymentProfile]
      request.profile.shipToList = [shippingAddress]
      request.validationMode = ValidationModeEnum::TestMode

      response = transaction.create_customer_profile(request)
      puts response.messages.resultCode
      if response != nil
        if response.messages.resultCode == MessageTypeEnum::Ok
          data.customer_profile_id = response.customerProfileId
          data.save!(:validate => false)
          puts "Successfully created a customer profile with id: #{response.customerProfileId}"
          puts "  Customer Payment Profile Id List:"
          response.customerPaymentProfileIdList.numericString.each do |id|
            puts "    #{id}"
          end
          puts "  Customer Shipping Address Id List:"
          response.customerShippingAddressIdList.numericString.each do |id|
            puts "    #{id}"
          end
          puts
        else
          puts response.messages.messages[0].code
          puts response.messages.messages[0].text
          raise "Failed to create a new customer profile."
        end
      else
        puts "Response is null"
        raise "Failed to create a new customer profile."
      end
      return response
    end

    def self.delete(customerProfileId)
      transaction = Conexion.get
      request = DeleteCustomerProfileRequest.new
      request.customerProfileId = customerProfileId
      response = transaction.delete_customer_profile(request)
      if response.messages.resultCode == MessageTypeEnum::Ok
        puts "Successfully deleted customer with customer profile ID #{request.customerProfileId}."
      else
        puts response.messages.messages[0].text
        raise "Failed to delete customer with customer profile ID #{request.customerProfileId}."
      end
      return response
    end

    def self.get (customerProfileId)
      transaction = Conexion.get
      request = GetCustomerProfileRequest.new
      request.customerProfileId = customerProfileId
      response = transaction.get_customer_profile(request)
      if response.messages.resultCode == MessageTypeEnum::Ok
        return response
      else
        return nil
      end

    end
  end
end