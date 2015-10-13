require "rails_helper"

RSpec.describe Statement do
  subject(:statement) { described_class.new }

  it "sets a uuid" do
    expect { statement.save }.to change { statement.uuid }
  end
end
