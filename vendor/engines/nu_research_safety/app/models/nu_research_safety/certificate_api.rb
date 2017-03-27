module NuResearchSafety

  class CertificateApi

    attr_reader :learner_id

    def initialize(learner_id, cert_name)
      @learner_id = learner_id
      @cert_name = cert_name
    end

    def self.certified?(learner_id, cert_name)
      new(learner_id, cert_name).certified?
    end

    def certified?
      # currently the NU API returns "Sucessfull" with 2 L's
      response["CompletionStatus"].start_with?("Successful")
    end

    private

    def response
      conn = Faraday.new(url: "https://nusoa.northwestern.edu") do |faraday|
        faraday.headers["Content-Type"] = "application/json"
        faraday.adapter Faraday.default_adapter
      end

      response = conn.get("/CheckCertCompletion", LearnerId: learner_id, CertName: formatted_cert_name)
      raise(CertificateApiError, response.body) unless response.success?

      JSON.parse(response.body)
    end

    def formatted_cert_name
      # API requires certificate names to end with "Certification"
      "#{@cert_name} Certification"
    end

  end

  class CertificateApiError < StandardError
  end

end
