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
    def form_fields
      base_fields.merge(:MAC => request_mac)
    end

    def form_action
      "https://securedt.dibspayment.com/verify/bin/#{@merchant}/index"
    end

    def valid_response?(mac, sum, reply, verify_id)
      response_mac(sum, reply, verify_id) == mac.upcase.split("=").last
    end

    def approved_reply?(reply)
      reply == APPROVED_REPLY
    end

    private

    def base_fields
      {
        :currency         => "SEK",
        :method           => "cc.test",
        :amount           => "100",
        :authOnly         => "true",
        :pageSet          => "creditcard",
        :data             => "001:auth:1:100:",
        :uses3dsecure     => "false",
        :billingFirstName => "First name",
        :billingLastName  => "Last name",
        :billingAddress   => "Address",
        :billingCity      => "City",
        :billingCountry   => "Country",
        :eMail            => "email@example.com"
      }.merge(@custom_fields)
    end

    def request_mac
      Mac.build [ base_fields[:data], base_fields[:currency], base_fields[:method], @secret_key ]
    end

    def response_mac(sum, reply, verify_id)
      Mac.build [ sum, base_fields[:currency], reply, verify_id, @secret_key ]
    end
  end
end
