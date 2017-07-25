require "ostruct"
require "debitech"

describe Debitech::WebApi do
  let(:secret_key) {
    { :secret_key => "secretkey" }
  }

  describe "form_fields" do
    it "include static values" do
      fields = Debitech::WebApi.new(secret_key).form_fields
      expect(fields[:currency]).to eq "SEK"
      expect(fields[:method]).to eq "cc.test"
    end

    it "is possible to override the values via the initializer" do
      fields = Debitech::WebApi.new(secret_key.merge(:fields => { :method => "cc.cekab" })).form_fields
      expect(fields[:method]).to eq "cc.cekab"
    end

    it "is possible to override the values via method parameters" do
      api = Debitech::WebApi.new(secret_key.merge(:fields => { :pageSet => "mydefault" }))

      expect(api.form_fields.fetch(:pageSet)).to eq "mydefault"
      expect(api.form_fields(pageSet: "override").fetch(:pageSet)).to eq "override"
    end

    it "calculates MAC" do
      expect(Debitech::WebApi.new({ :secret_key => "secretkey1" }).form_fields[:MAC]).to match /DF253765337968C5ED7E6EA530CD692942416ABE/
      expect(Debitech::WebApi.new({ :secret_key => "secretkey2" }).form_fields[:MAC]).to match /BEB3C370E37837734642111D44CA7E304A0F45F2/
    end

    it "accounts for overrides in the MAC" do
      mac_without_override = Debitech::WebApi.new({ :secret_key => "secretkey1" }).form_fields.fetch(:MAC)
      mac_with_override = Debitech::WebApi.new({ :secret_key => "secretkey1" }).form_fields(method: "other-method").fetch(:MAC)
      expect(mac_without_override).not_to eq(mac_with_override)
    end
  end

  describe "form_action" do
    it "return the url based on shop" do
      api = Debitech::WebApi.new({ :merchant => "myshop" })
      expect(api.form_action).to include "https://securedt.dibspayment.com/verify/bin/myshop/index"
    end
  end

  describe "approved_response?" do
    context "given reply is 'A' for approved" do
      it "is true" do
        api = Debitech::WebApi.new
        expect(api.approved_reply?("A")).to be true
      end
    end

    context "given reply is 'D' for denied" do
      it "is false" do
        api = Debitech::WebApi.new
        expect(api.approved_reply?("D")).to be false
      end
    end
  end

  describe "valid_response?" do
    it "validate that the response hashes down to the mac value" do
      api = Debitech::WebApi.new(secret_key)
      expect(api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", "1234567")).to be true
    end

    it "is not true if any of the values are wrong" do
      api = Debitech::WebApi.new(secret_key)
      expect(api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", "1234568")).to be false
    end

    it "is not true if the secretkey is different" do
      api = Debitech::WebApi.new({ :secret_key => "secretkey2" })
      expect(api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", "1234567")).to be false
    end

    it "handles if verify_id is an int" do
      api = Debitech::WebApi.new(secret_key)
      expect(api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", 1234567)).to be true
    end

    it "lets you pass currency explicitly" do
      api = Debitech::WebApi.new(secret_key)
      expect(api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", 1234567, "SEK")).to be true
      expect(api.valid_response?("MAC=667026AD7692F9AFDA362919EA72D8E6A250A849", "1,00", "A", 1234567, "EUR")).to be false
    end

    it "handles MAC based on reference_number" do
      api = Debitech::WebApi.new(secret_key)
      expect(api.valid_response?("MAC=AB4698D21798C6F3A1EA25CD67590A072211123D", "1,00", "A", "1234567", "SEK", "ref-123")).to be true
    end
  end
end
