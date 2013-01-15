module Pmu
  module NufsAccountExtension

    def to_s(with_owner = false)
      desc = super
      pmu_dept = PmuDepartment.find_by_nufin_id dept
      desc += " / #{pmu_dept.pmu}" if pmu_dept
      desc
    end

  end
end
