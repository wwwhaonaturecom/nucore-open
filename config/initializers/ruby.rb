#
# Changes to ruby core
#

class Numeric
  #
  # Equivalent of Ruby 1.9's Numeric#round
  def round_to(places)
    power = 10.0**places
    (self * power).round / power
  end
end
