$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "azure_direct_upload/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "azure_direct_upload"
  s.version     = AzureDirectUpload::VERSION
  s.authors     = ["Sology"]
  s.email       = ["contact@sology.eu"]
  s.homepage    = "https://github.com/Sology/azure_direct_upload"
  s.summary     = "Upload multiple files directly from client browser to Azure Blob Storage."
  s.description = s.summary
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1"
  s.add_dependency 'coffee-rails', '>= 3.1'
  s.add_dependency 'jquery-fileupload-rails', '~> 0.4'
  s.add_dependency 'azure', '~> 0.6'
  s.add_dependency 'azure-contrib', '~> 0.0.12'
  s.add_dependency 'addressable', '>= 2.2'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
