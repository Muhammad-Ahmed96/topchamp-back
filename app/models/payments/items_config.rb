module Payments
  class ItemsConfig
    def self.get_event
      return {id: "E", name: "Event", description: "Create event", unit_price: 200, taxable: true, tax: 0}
    end

    def self.get_bracket
      return {id: "Bracket", tax: 2.5}
    end
  end
end