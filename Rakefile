require 'rake/testtask'

task :console do
  require 'irb'
  require_relative 'lib/retail_transaction'

  tx = RetailTransaction.new
  binding.irb
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.libs << "lib"
  t.pattern = "test/*_test.rb"
end
