$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "formalizer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "formalizer"
  s.version     = Formalizer::VERSION
  s.authors     = ["Tal Yaniv, nrc2015"]
  s.email       = ["talyaniv@gmail.com"]
  s.platform    = Gem::Platform::RUBY
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.required_ruby_version = '~> 2.0'
  s.homepage    = "https://github.com/talyaniv/formalizer"
  s.summary     = "Generate filled PDF documents from template HTML forms"
  s.description = <<-eof
    Easily generate filled PDF documents from HTML templates.
    Formalizer takes HTML templates with styles and images, 
    replaces blank targets with dynamic user data and finally exports the filled forms
    into PDF or HTML.
  eof
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.5"
  s.add_dependency "nokogiri", "~> 1.6"
  s.add_dependency "wicked_pdf", "~> 1.0"
  s.add_dependency "wkhtmltopdf-binary", "~> 0"
end
