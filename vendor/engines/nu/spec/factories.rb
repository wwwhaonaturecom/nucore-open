FactoryGirl.modify do
  factory :journal_row do
    fund { 123 }
    dept { 1_234_567 }
  end
end
