require File.dirname(__FILE__) + '/run_strategy/local_process'

unless Spork.using_spork?
  test_framework = Spork::Runner.new([], STDERR, STDOUT).find_test_framework
  Spork::RunStrategy::LocalProcess.new(test_framework).run(ARGV, STDERR, STDOUT)
end
