class NucsDepartment < NucsGe001

  validates_format_of(:value, with: /\A[A-Z0-9]{7,10}\z/)

end
