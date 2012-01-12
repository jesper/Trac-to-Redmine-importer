require 'rake/testtask'

Rake::TestTask.new(:test) do |test|

  require 'simplecov'
  SimpleCov.start do
    add_filter "/tests/"
  end

  test.libs << 'lib' << 'test'
  test.test_files = FileList['tests/test_*.rb']
  test.verbose = true
end

task :default => :test

