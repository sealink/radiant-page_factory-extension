# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-page_factory-extension"

Gem::Specification.new do |s|
  s.name        = "radiant-page_factory-extension"
  s.version     = RadiantPageFactoryExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = RadiantPageFactoryExtension::AUTHORS
  s.email       = RadiantPageFactoryExtension::EMAIL
  s.homepage    = RadiantPageFactoryExtension::URL
  s.summary     = RadiantPageFactoryExtension::SUMMARY
  s.description = RadiantPageFactoryExtension::DESCRIPTION

  s.add_dependency "acts_as_list", "0.1.4"
  s.add_dependency "paperclip",    "~> 2.7.0"
  s.add_dependency "uuidtools",    "~> 2.1.2"
  s.add_dependency "cocaine",      "~> 0.3.2"

  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]

  s.post_install_message = %{
  Add this to your radiant project with:
    config.gem 'radiant-page_factory-extension', :version => '~>#{RadiantPageFactoryExtension::VERSION}'
  }
end
