require 'ostruct'
require 'debitech'

describe Debitech::WebApi, "form_fields" do
  it "should include static values" do
    fields = Debitech::WebApi.new({ :secret_key => 'secretkey' }).form_fields
    fields[:currency].should == 'SEK'
    fields[:method].should == 'cc.test'
  end

  it "should be possible to override the values" do
    fields = Debitech::WebApi.new({ :secret_key => 'secretkey', :fields => { :method => "cc.cekab" } }).form_fields
    fields[:method].should == 'cc.cekab'
  end

  it "should calculate mac" do
    Debitech::WebApi.new({ :secret_key => "secretkey1" }).form_fields[:MAC].should == "DF253765337968C5ED7E6EA530CD692942416ABE"
    Debitech::WebApi.new({ :secret_key => "secretkey2" }).form_fields[:MAC].should == "BEB3C370E37837734642111D44CA7E304A0F45F2"
  end
end

describe Debitech::WebApi, "form_action" do
  it "should return the url based on shop" do
    Debitech::WebApi.new({ :merchant => "shop" }).form_action.should == "https://secure.incab.se/verify/bin/shop/index"
  end
end

describe Debitech::WebApi, "approved_response?" do
  context "given reply is 'A' for approved" do
    it "should be true" do
      api = Debitech::WebApi.new
      api.approved_reply?("A").should be_true
    end
  end

  context "given reply is 'D' for denied" do
    it "should be false" do
      api = Debitech::WebApi.new
      api.approved_reply?("D").should be_false
    end
  end
end

describe Debitech::WebApi, "valid_response?" do
  it "should validate that the response hashes down to the mac value" do
    api = Debitech::WebApi.new({ :secret_key => "secretkey" })
    api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", "1234567").should be_true
  end

  it "should not be true if any of the values are wrong" do
    api = Debitech::WebApi.new({ :secret_key => "secretkey" })
    api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", "1234568").should be_false
  end

  it "should not be true if the secretkey is different" do
    api = Debitech::WebApi.new({ :secret_key => "secretkey2" })
    api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", "1234567").should be_false
  end

  it "should handle if verify_id is an int" do
    api = Debitech::WebApi.new({ :secret_key => "secretkey" })
    api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", 1234567).should be_true
  end

end 
