require "rails_helper"

RSpec.describe Payment do
  subject(:payment) { described_class.new }

  it "allows cardconnect as a source" do
    payment.assign_attributes(source: :cardconnect)
    payment.valid?
    expect(payment.errors).not_to include(:source)
  end
end
