require "digest/sha1"
require "debitech/mac"

module Debitech
  class WebApi
    APPROVED_REPLY = "A"

    def initialize(opts = {})
      @merchant = opts.fetch(:merchant, nil)
      @secret_key = opts.fetch(:secret_key, nil)
      @custom_fields = opts.fetch(:fields, {})
    end

    # you probably want to encode these when posting to dibs, for example HTMLEntities.new.encode(v, :named) (gem: htmlentities)
    def form_fields(more_custom_fields = {})
      # Overriding via the initializer may be more convenient for per-env stuff like "method".
      # Overriding via the method argument may be more convenient for per-request stuff like multiple pageSets.
      all_fields_except_mac = custom_fields.merge(more_custom_fields)
      mac = request_mac(all_fields_except_mac)
      all_fields_except_mac.merge(MAC: mac)
    end

    def form_action
      "https://securedt.dibspayment.com/verify/bin/#{@merchant}/index"
    end

    # If the currency was passed into form_fields (and thus isn't known on an instance level),
    # you will need to pass it in explicitly here.
    def valid_response?(mac, sum, reply, verify_id, currency = custom_fields[:currency], reference_number = nil)
      response_mac(sum, reply, verify_id, currency, reference_number) == mac.upcase.split("=").last
    end

    def approved_reply?(reply)
      reply == APPROVED_REPLY
    end

    private

    def custom_fields
      base_fields.merge(@custom_fields)
    end

    def base_fields
      {
        currency: "SEK",
        method: "cc.test",
        amount: "100",
        authOnly: "true",
        pageSet: "creditcard",
        data: "001:auth:1:100:",
        billingFirstName: "First name",
        billingLastName: "Last name",
        billingAddress: "Address",
        billingCity: "City",
        billingCountry: "Country",
        eMail: "email@example.com",
      }
    end

    private

    def request_mac(fields)
      verify_id = fields[:verifyID]

      if verify_id
        Mac.build [ fields[:data], fields[:currency], fields[:method], @secret_key, verify_id ]
      else
        Mac.build [ fields[:data], fields[:currency], fields[:method], @secret_key ]
      end
    end

    def response_mac(sum, reply, verify_id, currency, reference_number)
      # Reference number is optional, but if it's passed in when making the payment it
      # needs to be part of the response_mac calculation to verify the payment result.
      if reference_number
        Mac.build [ sum, currency, reply, verify_id, reference_number, @secret_key ]
      else
        Mac.build [ sum, currency, reply, verify_id, @secret_key ]
      end
    end
  end
end
