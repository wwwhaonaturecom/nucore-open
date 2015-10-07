require "rails_helper"

RSpec.describe Product do
  it 'should allow an expense account starting with a 7' do
    product = Product.new(:account => '71234')
    product.valid?
    expect(product.errors).not_to include :account
  end

  it 'should not allow an expense account starting with a 4' do
    product = Product.new(:account => '41234')
    product.valid?
    expect(product.errors).to include :account
  end

  it 'should not allow an expense account starting with a 5' do
    product = Product.new(:account => '51234')
    product.valid?
    expect(product.errors).to include :account
  end
end
