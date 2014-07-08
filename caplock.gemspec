# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "caplock"
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dru Ibarra", "Giorgio Premi"]
  s.date = "2014-07-08"
  s.description = "Adds a lock file to Capistrano deployments to prevent concurrent deployments."
  s.email = "Druwerd@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "caplock.gemspec",
    "lib/caplock.rb",
    "test/helper.rb",
    "test/test_caplock.rb"
  ]
  s.homepage = "http://github.com/Druwerd/caplock"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Adds a lock file to Capistrano deployments"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, [">= 2.9.0"])
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    else
      s.add_dependency(%q<capistrano>, [">= 2.9.0"])
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    end
  else
    s.add_dependency(%q<capistrano>, [">= 2.9.0"])
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
  end
end

