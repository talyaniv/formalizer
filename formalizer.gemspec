$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "formalizer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "formalizer"
  s.version     = Formalizer::VERSION
  s.authors     = ["Tal Yaniv, nrc2015"]
  s.email       = ["tal@reali.com"]
  s.platform    = Gem::Platform::RUBY
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.homepage    = "TODO"
  s.summary     = "Generate filled PDF documents from template HTML forms"
  s.description = <<-eof
    Easily generate beautiful filled PDF documents from HTML forms. Create your forms in HTML, including style and pictures, then use param/value pairs to fill the forms and finally export everything to a nicely format PDF file.
  eof
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.3"

  s.add_development_dependency "sqlite3"
end
