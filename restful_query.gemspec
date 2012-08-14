# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "restful_query"
  s.version = "0.3.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Quint"]
  s.date = "2012-08-14"
  s.description = "RestfulQuery provides a simple interface in front of a complex parser to parse specially formatted query hashes into complex SQL queries. It includes ActiveRecord and Sequel extensions."
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "History.txt",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "init.rb",
    "lib/restful_query.rb",
    "lib/restful_query/can_query.rb",
    "lib/restful_query/condition.rb",
    "lib/restful_query/parser.rb",
    "lib/restful_query/rails.rb",
    "lib/restful_query/sort.rb",
    "lib/sequel/extensions/restful_query.rb",
    "rails/init.rb",
    "restful_query.gemspec",
    "tasks/restful_query_tasks.rake",
    "test/test_helper.rb",
    "test/test_restful_query_can_query.rb",
    "test/test_restful_query_condition.rb",
    "test/test_restful_query_parser.rb",
    "test/test_restful_query_sort.rb"
  ]
  s.require_paths = ["lib"]
  s.rubyforge_project = "quirkey"
  s.rubygems_version = "1.8.24"
  s.summary = "Simple ActiveRecord and Sequel queries from a RESTful and safe interface"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.2.0"])
      s.add_runtime_dependency(%q<chronic>, [">= 0.2.3"])
      s.add_development_dependency(%q<Shoulda>, [">= 1.2.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.2.0"])
      s.add_dependency(%q<chronic>, [">= 0.2.3"])
      s.add_dependency(%q<Shoulda>, [">= 1.2.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.2.0"])
    s.add_dependency(%q<chronic>, [">= 0.2.3"])
    s.add_dependency(%q<Shoulda>, [">= 1.2.0"])
  end
end

