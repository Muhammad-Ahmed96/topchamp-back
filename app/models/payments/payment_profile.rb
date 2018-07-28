include AuthorizeNet::API
module Payments
  class PaymentProfile
    include Swagger::Blocks
    def self.create(data, cardNumber, expirationDate)
      transaction = Conexion.get
      # Build the payment object
      payment = PaymentType.new(CreditCardType.new)
      payment.creditCard.cardNumber = cardNumber
      payment.creditCard.expirationDate = expirationDate

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
      #paymentProfile.billTo = billTo
      paymentProfile.defaultPaymentProfile = true

      # Build the request object
      request = CreateCustomerPaymentProfileRequest.new
      request.paymentProfile = paymentProfile
      request.customerProfileId = data.customer_profile_id
      request.validationMode = ValidationModeEnum::TestMode

      response = transaction.create_customer_payment_profile(request)

      if response != nil
        if response.messages.resultCode == MessageTypeEnum::Ok
          puts "Successfully created a customer payment profile with id: #{response.customerPaymentProfileId}."
        else
          puts response.messages.messages[0].code
          puts response.messages.messages[0].text
          puts "Failed to create a new customer payment profile."
          raise response.messages.messages[0].text
        end
      else
        puts "Response is null"
        raise "Failed to create a new customer payment profile."
      end
      return response
    end


    def self.get_list(customer_profile_id)
      transaction = Conexion.get

      searchTypeEnum = CustomerPaymentProfileSearchTypeEnum::CardsExpiringInMonth
      sorting = CustomerPaymentProfileSorting.new
      orderByEnum = CustomerPaymentProfileOrderFieldEnum::Id
      sorting.orderBy = orderByEnum
      sorting.orderDescending = false

      paging = Paging.new
      paging.limit = 1000
      paging.offset = 1


      request = GetCustomerPaymentProfileListRequest.new
      #request.customerProfileId = customer_profile_id
      request.searchType = searchTypeEnum
      request.month = "2030-05"
      request.sorting = sorting
      request.paging = paging

      response = transaction.get_customer_payment_profile_list(request)

      if response.messages.resultCode == MessageTypeEnum::Ok
        puts "Successfully got customer payment profile list."
        puts response.messages.messages[0].code
        puts response.messages.messages[0].text
        puts "  Total number in result set: #{response.totalNumInResultSet}"
#      response.paymentProfiles.paymentProfile.each do |paymentProfile|
#        puts "Payment profile ID = #{paymentProfile.customerPaymentProfileId}"
#        puts "First Name in Billing Address = #{paymentProfile.billTo.firstName}"
#        puts "Credit Card Number = #{paymentProfile.payment.creditCard.cardNumber}"
#      end
      else
        puts response.messages.messages[0].code
        puts response.messages.messages[0].text
        raise response.messages.messages[0].text
      end
      return response
    end

    def self.getItemsFormat(items)
      data = []

      items.each do |item|
        data << {:defaultPaymentProfile => item.defaultPaymentProfile, :customerPaymentProfileId => item.customerPaymentProfileId,
                 :payment => {:creditCard => {:cardNumber => item.payment.creditCard.cardNumber, :expirationDate => item.payment.creditCard.expirationDate, :cardType => item.payment.creditCard.cardType,
                                              :issuerNumber => item.payment.creditCard.issuerNumber, :isPaymentToken => item.payment.creditCard.isPaymentToken}},
                 :customerType => item.customerType}
      end
      return data
    end


    def self.delete(customerProfileId, customerPaymentProfileId)
      transaction = Conexion.get
      request = DeleteCustomerPaymentProfileRequest.new
      request.customerProfileId = customerProfileId
      request.customerPaymentProfileId = customerPaymentProfileId

      response = transaction.delete_customer_payment_profile(request)


      if response.messages.resultCode == MessageTypeEnum::Ok
        puts "Successfully deleted payment profile with customer payment profile ID #{request.customerPaymentProfileId}."
      else
        puts "Failed to delete payment profile with profile ID #{request.customerPaymentProfileId}: #{response.messages.messages[0].text}"
      end
      return response
    end


    swagger_schema :PaymentProfile do
      property :defaultPaymentProfile do
        key :type, :boolean
      end
      property :customerPaymentProfileId do
        key :type, :string
      end
      property :payment do
        property :creditCard do
          key :'$ref', :CreditCard
        end
      end
      property :customerType do
        key :type, :string
      end
    end
  end
end