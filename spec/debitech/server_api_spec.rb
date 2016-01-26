require "debitech"

describe Debitech::ServerApi, "charge" do
  let(:unique_reference) {
    { :unique_reference => "some_unique_ref" }
  }

  let(:transaction) {
    { :verify_id => 1234567, :amount => 2235, :currency => "SEK", :ip => "127.0.0.1" }.merge(unique_reference)
  }

  it "should perform a subscribe_and_settle call" do
    settings = {
      :secret_key => "112756FC8C60C5603C58DA6E0A4844ACFDB60525",
      :method => "cc.cekab",
      :soap_opts => {
        :merchant => "store",
        :username => "api_user",
        :password => "api_password"
      }
    }

    soap_api = double
    allow(DebitechSoap::API).to receive(:new).with({ :merchant => "store", :username => "api_user", :password => "api_password" }).
                                           and_return(soap_api)
    expect(soap_api).to receive(:subscribe_and_settle).with(:verifyID => 1234567,
                            :data => "001:payment:1:10000:",
                            :ip => "127.0.0.1",
                            :extra => "&method=cc.cekab&currency=SEK&MAC=1931EE498A77F6B12B2C2D2EC8599719EF9CE419&referenceNo=some_unique_ref")

    server_api = Debitech::ServerApi.new(settings)
    server_api.charge(transaction.merge(:amount => 10000))
  end

  it "should convert the amount to a integer to avoid 500 errors" do
    soap_api = double
    allow(DebitechSoap::API).to receive(:new).and_return(soap_api)
    expect(soap_api).to receive(:subscribe_and_settle).with(:verifyID => 1234567,
                            :data => "001:payment:1:2235:",
                            :ip => "127.0.0.1",
                            :extra => "&method=&currency=SEK&MAC=78B1144270B1A74A55539FAEB81BB49EC39B90DF&referenceNo=some_unique_ref")

    server_api = Debitech::ServerApi.new({})
    server_api.charge(transaction.merge(:amount => 2235.0))
  end

  it "should raise an error if the amount has a fraction" do
    soap_api = double
    allow(DebitechSoap::API).to receive(:new).and_return(soap_api)
    server_api = Debitech::ServerApi.new({})
    expect {
      server_api.charge(transaction.merge(:amount => 2235.55))
    }.to raise_error("The amount (2235.55) contains fractions (for example 10.44 instead of 10), amount should specified in cents.")
  end

  it "should raise an error if the unique_reference is nil" do
    soap_api = double
    allow(DebitechSoap::API).to receive(:new).and_return(soap_api)
    server_api = Debitech::ServerApi.new({})
    expect {
      server_api.charge(transaction.merge(:unique_reference => nil))
    }.to raise_error(Debitech::ServerApi::ValidUniqueReferenceRequired)
  end

  it "should raise an error if the unique_reference is less than 4 characters" do
    soap_api = double
    allow(DebitechSoap::API).to receive(:new).and_return(soap_api)
    server_api = Debitech::ServerApi.new({})
    expect {
      server_api.charge(transaction.merge(:unique_reference => "1234"))
    }.to raise_error(Debitech::ServerApi::ValidUniqueReferenceRequired)
  end

  it "should be valid with a 5 character unique_reference" do
    soap_api = double
    allow(DebitechSoap::API).to receive(:new).and_return(soap_api)
    allow(soap_api).to receive(:subscribe_and_settle)
    server_api = Debitech::ServerApi.new({})
    server_api.charge(transaction.merge(:unique_reference => "12345"))
  end

  [ 100, 101, 150, 199 ].each do |result_code|
    it "should return success for result_code #{result_code}" do
      soap_api = double
      allow(DebitechSoap::API).to receive(:new).and_return(soap_api)
      response = double(:result_code => result_code)
      allow(soap_api).to receive(:subscribe_and_settle).and_return(response)

      server_api = Debitech::ServerApi.new({})
      result = server_api.charge(unique_reference)

      expect(result).to be_success
      expect(result).not_to be_pending
      expect(result.response.result_code).to eql result_code
    end
  end

  [ 200, 250, 300, 400 ].each do |result_code|
    it "should not be successful for result_code #{result_code}" do
      soap_api = double
      allow(DebitechSoap::API).to receive(:new).and_return(soap_api)
      response = double(:result_code => result_code)
      allow(soap_api).to receive(:subscribe_and_settle).and_return(response)

      server_api = Debitech::ServerApi.new({})
      result = server_api.charge(unique_reference)

      expect(result).not_to be_success
      expect(result).not_to be_pending
      expect(result.response.result_code).to eql result_code
    end
  end

  it "should return pending and not be successful for 403" do
    soap_api = double
    allow(DebitechSoap::API).to receive(:new).and_return(soap_api)
    response = double(:result_code => 403)
    allow(soap_api).to receive(:subscribe_and_settle).and_return(response)
    server_api = Debitech::ServerApi.new({})
    result = server_api.charge(unique_reference)

    expect(result).not_to be_success
    expect(result).to be_pending
  end
end
