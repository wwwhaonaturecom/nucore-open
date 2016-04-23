RSpec::Matchers.define :access_the_page do
  failure_message do |actual|
    "render successfully with a 200 or 302, but was #{actual.code}"
  end

  match do |actual|
    actual.code.in?("200", "302")
  end
end