require 'ostruct'
require 'debitech'

describe Debitech::WebApi do
  let(:secret_key) {
    { :secret_key => "secretkey" }
  }

  describe "form_fields" do
    it "include static values" do
      fields = Debitech::WebApi.new(secret_key).form_fields
      expect(fields[:currency]).to match /SEK/
      expect(fields[:method]).to match /cc.test/
    end

    it "is possible to override the values" do
      fields = Debitech::WebApi.new(secret_key.merge(:fields => { :method => "cc.cekab" })).form_fields
      expect(fields[:method]).to match /cc.cekab/
    end

    it "calculate mac" do
      expect(Debitech::WebApi.new({ :secret_key => "secretkey1" }).form_fields[:MAC]).to match /DF253765337968C5ED7E6EA530CD692942416ABE/
      expect(Debitech::WebApi.new({ :secret_key => "secretkey2" }).form_fields[:MAC]).to match /BEB3C370E37837734642111D44CA7E304A0F45F2/
    end
  end

  describe "form_action" do
    it "return the url based on shop" do
      expect(Debitech::WebApi.new({ :merchant => "shop" }).form_action).to include "https://secure.incab.se/verify/bin/shop/index"
    end
  end

  describe "approved_response?" do
    context "given reply is 'A' for approved" do
      it "is true" do
        api = Debitech::WebApi.new
        expect(api.approved_reply?("A")).to be_true
      end
    end

    context "given reply is 'D' for denied" do
      it "is false" do
        api = Debitech::WebApi.new
        expect(api.approved_reply?("D")).to be_false
      end
    end
  end

  describe "valid_response?" do
    it "validate that the response hashes down to the mac value" do
      api = Debitech::WebApi.new(secret_key)
      expect(api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", "1234567")).to be_true
    end

    it "is not true if any of the values are wrong" do
      api = Debitech::WebApi.new(secret_key)
      expect(api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", "1234568")).to be_false
    end

    it "is not true if the secretkey is different" do
      api = Debitech::WebApi.new({ :secret_key => "secretkey2" })
      expect(api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", "1234567")).to be_false
    end

    it "handle if verify_id is an int" do
      api = Debitech::WebApi.new(secret_key)
      expect(api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", 1234567)).to be_true
    end
  end
end
