class NucsAccount < NucsGe001

  validates_format_of(:value, with: /\A\d{5,10}\z/)

end
