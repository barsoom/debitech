require 'debitech'

describe Debitech::ServerApi, "charge" do

  it "should perform a subscribe_and_settle call" do
    settings = {
      :secret_key => "112756FC8C60C5603C58DA6E0A4844ACFDB60525",
      :method => "cc.cekab",
      :soap_opts => { :merchant => "store", :username => "api_user", :password => "api_password" } }

    DebitechSoap::API.should_receive(:new).with({ :merchant => "store", :username => "api_user", :password => "api_password" }).
                                           and_return(soap_api = mock)
    soap_api.should_receive(:subscribe_and_settle).with(:verifyID => 1234567,
                            :data => "001:payment:1:10000:",
                            :ip => "127.0.0.1",
                            :extra => "&method=cc.cekab&currency=SEK&MAC=1931EE498A77F6B12B2C2D2EC8599719EF9CE419&referenceNo=some_unique_ref")

    server_api = Debitech::ServerApi.new(settings)
    server_api.charge(:verify_id => 1234567, :amount => 10000, :currency => "SEK", :unique_reference => "some_unique_ref", :ip => "127.0.0.1")
  end

  it "should convert the amount to a integer to avoid 500 errors" do
    DebitechSoap::API.stub!(:new).and_return(soap_api = mock)
    soap_api.should_receive(:subscribe_and_settle).with(:verifyID => 1234567,
                            :data => "001:payment:1:2235:",
                            :ip => "127.0.0.1",
                            :extra => "&method=&currency=SEK&MAC=78B1144270B1A74A55539FAEB81BB49EC39B90DF&referenceNo=some_unique_ref")

    server_api = Debitech::ServerApi.new({})
    server_api.charge(:verify_id => 1234567, :amount => 2235.0, :currency => "SEK", :unique_reference => "some_unique_ref", :ip => "127.0.0.1")
  end

  it "should raise an error if the amount has a fraction" do
    DebitechSoap::API.stub!(:new).and_return(soap_api = mock)
    server_api = Debitech::ServerApi.new({})
    lambda {
      server_api.charge(:verify_id => 1234567, :amount => 2235.55, :currency => "SEK", :unique_reference => "some_unique_ref", :ip => "127.0.0.1")
    }.should raise_error("The amount (2235.55) contains fractions (for example 10.44 instead of 10), amount should specified in cents.")
  end

  it "should raise an error if the unique_reference is nil" do
    DebitechSoap::API.stub!(:new).and_return(soap_api = mock)
    server_api = Debitech::ServerApi.new({})
    lambda {
      server_api.charge(:verify_id => 1234567, :amount => 2235, :currency => "SEK", :unique_reference => nil, :ip => "127.0.0.1")
    }.should raise_error(Debitech::ServerApi::ValidUniqueReferenceRequired)
  end

  it "should raise an error if the unique_reference is less than 4 characters" do
    DebitechSoap::API.stub!(:new).and_return(soap_api = mock)
    server_api = Debitech::ServerApi.new({})
    lambda {
      server_api.charge(:verify_id => 1234567, :amount => 2235, :currency => "SEK",
                        :unique_reference => "1234", :ip => "127.0.0.1")
    }.should raise_error(Debitech::ServerApi::ValidUniqueReferenceRequired)
  end

  it "should be valid with a 5 character unique_reference" do
    DebitechSoap::API.stub!(:new).and_return(soap_api = mock)
    soap_api.stub!(:subscribe_and_settle)
    server_api = Debitech::ServerApi.new({})
    server_api.charge(:verify_id => 1234567, :amount => 2235, :currency => "SEK",
                      :unique_reference => "12345", :ip => "127.0.0.1")
  end

  [ 100, 101, 150, 199 ].each do |result_code|
    it "should return success for result_code #{result_code}" do
      DebitechSoap::API.stub!(:new).and_return(soap_api = mock)
      soap_api.stub!(:subscribe_and_settle).and_return(response = mock(:result_code => result_code))

      server_api = Debitech::ServerApi.new({})
      result = server_api.charge({ :unique_reference => "some_unique_ref" })

      result.should be_success
      result.should_not be_pending
      result.response.result_code.should == result_code
    end
  end

  [ 200, 250, 300, 400 ].each do |result_code|
    it "should not be successful for result_code #{result_code}" do
      DebitechSoap::API.stub!(:new).and_return(soap_api = mock)
      soap_api.stub!(:subscribe_and_settle).and_return(response = mock(:result_code => result_code))

      server_api = Debitech::ServerApi.new({})
      result = server_api.charge({ :unique_reference => "some_unique_ref" })

      result.should_not be_success
      result.should_not be_pending
      result.response.result_code.should == result_code
    end
  end

  it "should return pending and not be successful for 403" do
    DebitechSoap::API.stub!(:new).and_return(soap_api = mock)
    soap_api.stub!(:subscribe_and_settle).and_return(response = mock(:result_code => 403))
    server_api = Debitech::ServerApi.new({})
    result = server_api.charge({ :unique_reference => "some_unique_ref" })

    result.should_not be_success
    result.should be_pending
  end

end
