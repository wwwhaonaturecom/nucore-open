require 'spec_helper'

describe Product do
  it 'should allow an expense account starting with a 7' do
    product = Product.new(:account => '71234')
    product.valid?
    product.errors.should_not include :account
  end

  it 'should not allow an expense account starting with a 4' do
    product = Product.new(:account => '41234')
    product.valid?
    product.errors.should include :account
  end

  it 'should not allow an expense account starting with a 5' do
    product = Product.new(:account => '51234')
    product.valid?
    product.errors.should include :account
  end
end