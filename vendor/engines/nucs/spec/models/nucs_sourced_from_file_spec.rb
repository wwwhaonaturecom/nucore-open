require "rails_helper"

RSpec.describe NucsGrantsBudgetTree do
  it "should delete all records in the DB and successfully ingest a source file" do
    source = File.join(File.dirname(__FILE__), "..", "files", "grants_budget_tree.txt")
    gbt = FactoryGirl.create(:nucs_grants_budget_tree)
    NucsGrantsBudgetTree.source(source)
    expect(NucsGrantsBudgetTree.count).to eq(10)
    assert !NucsGrantsBudgetTree.exists?(gbt.id)
  end
end
