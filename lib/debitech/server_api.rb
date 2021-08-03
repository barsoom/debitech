require "debitech_soap"
require "debitech/mac"

module Debitech
  class ServerApi
    class ChargeResult
      attr_reader :response

      PENDING_RESULT_CODE = 403

      def initialize(response)
        @response = response
      end

      def success?
        @response.result_code.to_s[0, 1] == "1"
      end

      def pending?
        @response.result_code == PENDING_RESULT_CODE
      end
    end

    class ValidUniqueReferenceRequired < StandardError; end

    # Don't know about the upper bound, but we need it to be atleast 5 characters to be
    # able to search for it in DIBS Manager.
    LEAST_NUMBER_OF_CHARACTERS_IN_UNIQUE_ID = 5

    def initialize(config = {})
      @config = config
      @soap_api = DebitechSoap::API.new(config[:soap_opts])
    end

    def charge(opts = {})
      if opts[:amount] && (opts[:amount] - opts[:amount].to_i) > 0
        raise "The amount (#{opts[:amount]}) contains fractions (for example 10.44 instead of 10), amount should specified in cents."
      end

      if opts[:unique_reference].to_s.size < LEAST_NUMBER_OF_CHARACTERS_IN_UNIQUE_ID
        raise ValidUniqueReferenceRequired
      end

      data = "001:payment:1:#{opts[:amount].to_i}:"
      mac = Mac.build [ data, opts[:currency], opts[:unique_reference], @config[:secret_key] ]
      extra = "&method=#{@config[:method]}&currency=#{opts[:currency]}&MAC=#{mac}&referenceNo=#{opts[:unique_reference]}"
      response = @soap_api.subscribe_and_settle(:verifyID => opts[:verify_id], :ip => opts[:ip], :data => data, :extra => extra)
      ChargeResult.new(response)
    end
  end
end
