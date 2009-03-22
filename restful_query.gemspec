# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{restful_query}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Quint"]
  s.date = %q{2009-03-21}
  s.description = %q{Simple ActiveRecord queries from a RESTful and safe interface}
  s.email = ["aaron@quirkey.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["History.txt", "LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "init.rb", "lib/restful_query.rb", "lib/restful_query/can_query.rb", "lib/restful_query/condition.rb", "lib/restful_query/parser.rb", "lib/restful_query/sort.rb", "rails/init.rb", "restful_query.gemspec", "tasks/restful_query_tasks.rake", "test/test_helper.rb", "test/test_restful_query_can_query.rb", "test/test_restful_query_condition.rb", "test/test_restful_query_parser.rb", "test/test_restful_query_sort.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://code.quirkey.com/restful_query}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{quirkey}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Simple ActiveRecord queries from a RESTful and safe interface}
  s.test_files = ["test/test_helper.rb", "test/test_restful_query_can_query.rb", "test/test_restful_query_condition.rb", "test/test_restful_query_parser.rb", "test/test_restful_query_sort.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.2.0"])
      s.add_runtime_dependency(%q<activerecord>, [">= 2.2.0"])
      s.add_runtime_dependency(%q<chronic>, [">= 0.2.3"])
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<Shoulda>, [">= 1.2.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.2.0"])
      s.add_dependency(%q<activerecord>, [">= 2.2.0"])
      s.add_dependency(%q<chronic>, [">= 0.2.3"])
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<Shoulda>, [">= 1.2.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.2.0"])
    s.add_dependency(%q<activerecord>, [">= 2.2.0"])
    s.add_dependency(%q<chronic>, [">= 0.2.3"])
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<Shoulda>, [">= 1.2.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end