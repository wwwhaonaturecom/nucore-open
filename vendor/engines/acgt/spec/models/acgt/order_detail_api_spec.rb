require "rails_helper"

RSpec.describe Acgt::OrderDetailApi do
  describe "#order" do
    before do
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get("301172-349110") { |env| [200, {}, json] }
      end
      test = Faraday.new do |builder|
        builder.adapter :test, stubs
      end
      allow(Faraday).to receive(:new).and_return(test)
    end

    subject(:api) { described_class.find("301172-349110") }

    describe "when the response says it is submitted" do
      let(:json) do
        {
          order: [
            {
              orderid: "301172-349110",
              orderstatus: "Submit",
              orderdate: "2016-05-20T14:38:23Z",
              completeddate: "",
              firstname: "Kwang",
              lastname: "Shin",
              emailaddress: "kwang_shin@acgtinc.com",
              samplenumber: "0"
            }
          ]
        }.to_json
      end

      it "is is new" do
        expect(api).to be_new

        expect(api).not_to be_in_process
        expect(api).not_to be_complete
        expect(api).not_to be_canceled
      end
    end

    describe "when the response says it is Repeated" do
      let(:json) do
        {
          order: [
            {
              orderid: "301172-349110",
              orderstatus: "Repeated",
              orderdate: "2016-05-20T14:38:23Z",
              completeddate: "",
              firstname: "Kwang",
              lastname: "Shin",
              emailaddress: "kwang_shin@acgtinc.com",
              samplenumber: "0"
            }
          ]
        }.to_json
      end

      it "is is in process" do
        expect(api).to be_in_process

        expect(api).not_to be_new
        expect(api).not_to be_complete
        expect(api).not_to be_canceled
      end
    end

    describe "when it is completed" do
      let(:json) do
        {
          order: [
            {
              orderid: "301172-349110",
              orderstatus: "Completed",
              orderdate: "2016-05-20T14:38:23Z",
              completeddate: "",
              firstname: "Kwang",
              lastname: "Shin",
              emailaddress: "kwang_shin@acgtinc.com",
              samplenumber: "0"
            }
          ]
        }.to_json
      end

      it "is completed" do
        expect(api).to be_complete

        expect(api).not_to be_new
        expect(api).not_to be_in_process
        expect(api).not_to be_canceled
      end
    end

    describe "when it is canceled" do
      let(:json) do
        {
          order: [
            {
              orderid: "301172-349110",
              orderstatus: "Cancel",
              orderdate: "2016-05-20T14:38:23Z",
              completeddate: "",
              firstname: "Kwang",
              lastname: "Shin",
              emailaddress: "kwang_shin@acgtinc.com",
              samplenumber: "0"
            }
          ]
        }.to_json
      end

      it "is canceled" do
        expect(api).to be_canceled

        expect(api).not_to be_new
        expect(api).not_to be_in_process
        expect(api).not_to be_complete
      end
    end

    describe "when no order found" do
      let(:json) do
        {
          order: []
        }.to_json
      end

      it "raises an error" do
        expect { api }.to raise_error(Acgt::ApiError)
      end
    end
  end
end
