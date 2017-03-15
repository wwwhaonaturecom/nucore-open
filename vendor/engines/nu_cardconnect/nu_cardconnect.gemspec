$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "nu_cardconnect/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "nu_cardconnect"
  s.version     = NuCardconnect::VERSION
  s.authors     = ["Table XI"]
  s.email       = ["devs@tablexi.com"]
  s.homepage    = ""
  s.summary     = "CardConnect integration for Northwestern University."
  s.description = "CardConnect integration for Northwestern University."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails"
  s.add_dependency "cardconnect"
  s.add_dependency "c2po"
end
