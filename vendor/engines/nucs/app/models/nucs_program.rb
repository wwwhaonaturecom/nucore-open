class NucsProgram < NucsGe001

  validates_format_of(:value, with: /\A\d{4,5}\z/)

end
