module Pmu
  module GeneralReportsControllerExtension

    def department
      render_report(6, 'Name') {|od| od.account.respond_to?(:pmu_description) ? od.account.pmu_description : 'Unknown'  }
    end

  end
end
