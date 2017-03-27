require "rails_helper"

RSpec.describe NuResearchSafety::CertificateApi do
  before do
    stubs = Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get("/CheckCertCompletion") { |_env| [200, {}, json] }
    end
    test = Faraday.new do |builder|
      builder.adapter :test, stubs
    end
    allow(Faraday).to receive(:new).and_return(test)
  end

  describe ".certified?" do
    context "for a certified learner" do
      let(:json) do
        {
          LearnerId: "abc123",
          CertName: "Biological Safety Certification",
          CompletionStatus: "Successfull",
          Response: {
            Status: "OK",
          },
        }.to_json
      end

      it "returns true" do
        expect(NuResearchSafety::CertificateApi.certified?("abc123", "Biological Safety Certification")).to be_truthy
      end
    end

    context "for an uncertified learner" do
      let(:json) do
        {
          LearnerId: "abc123",
          CertName: "Biological Safety Certification",
          CompletionStatus: "Unsuccessful",
          Response: {
            Status: "OK",
          },
        }.to_json
      end

      it "returns false" do
        expect(NuResearchSafety::CertificateApi.certified?("abc123", "Biological Safety Certification")).to be_falsy
      end
    end

    context "for a certified learner" do
      let(:json) do
        {
          LearnerId: "abc123",
          CertName: "Biological Safety Certification",
          CompletionStatus: "",
          Response: {
            Status: "BadRequest",
          },
        }.to_json
      end

      it "returns false" do
        expect(NuResearchSafety::CertificateApi.certified?("abc123", "Biological Safety Certification")).to be_falsy
      end
    end
  end
end
