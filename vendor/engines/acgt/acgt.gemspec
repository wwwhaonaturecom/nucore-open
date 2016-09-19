$LOAD_PATH.push File.expand_path("../lib", __FILE__)

require "acgt/version"

Gem::Specification.new do |s|
  s.name = "acgt"
  s.version = Acgt::VERSION
  s.authors = ["Table XI"]
  s.email = "devs@tablexi.com"
  s.homepage = "https://github.com/tablexi/nucore-open"
  s.summary = "ACGT API"
  s.description = ""

  s.files = Dir["{app,config,lib,spec}/**/*"]

  s.add_dependency "sanger_sequencing"
end
