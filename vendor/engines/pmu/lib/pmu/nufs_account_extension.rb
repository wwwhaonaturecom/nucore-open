module Pmu

  module NufsAccountExtension

    def pmu_description
      PmuDepartment.find_by_nufin_id(dept).try :pmu
    end

    def to_s(with_owner = false, flag_suspended = true)
      desc = super(with_owner, false)
      pmu_desc = pmu_description
      desc += " / #{pmu_desc}" if pmu_desc
      desc += " (SUSPENDED)" if flag_suspended && suspended?
      desc
    end

  end

end
