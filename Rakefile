%w[rubygems rake rake/clean rake/testtask fileutils].each { |f| require f }
require File.dirname(__FILE__) + '/lib/restful_query'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = %q{restful_query}
    s.version = RestfulQuery::VERSION
    s.authors = ["Aaron Quint"]
    s.summary = 'Simple ActiveRecord and Sequel queries from a RESTful and safe interface'
    s.description   = %q{RestfulQuery provides a simple interface in front of a complex parser to parse specially formatted query hashes into complex SQL queries. It includes ActiveRecord and Sequel extensions.}
    s.rubyforge_project = %q{quirkey}
    s.add_runtime_dependency(%q<activesupport>, [">= 2.2.0"])
    s.add_runtime_dependency(%q<chronic>, ["~>0.10", ">= 0.10.2"])
    s.add_development_dependency(%q<rake>, ["~>10.4", ">= 10.4.2"])
    s.add_development_dependency(%q<minitest>, ["~> 5.5", ">= 5.5.0"])
    s.add_development_dependency(%q<shoulda>, [">= 2.9.0"])
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => :test
