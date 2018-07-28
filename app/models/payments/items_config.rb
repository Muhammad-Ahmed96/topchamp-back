module Payments
  class ItemsConfig
    def self.get_event
      return {id: "E-1", name: "Event", description: "Create event", unit_price: 200, taxable: true, tax: 0}
    end
  end
end