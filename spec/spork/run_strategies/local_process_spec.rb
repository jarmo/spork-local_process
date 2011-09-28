require File.dirname(__FILE__) + '/../../../lib/spork/run_strategy/local_process'

describe Spork::RunStrategy::LocalProcess do
  it "doesn't run LocalProcess when Spork is used with server" do
    Spork.should_receive(:using_spork?).and_return(true)
    Spork::RunStrategy::LocalProcess.should_not_receive(:run)
    load File.dirname(__FILE__) + "/../../../lib/spork/local_process.rb"
  end

  it "runs LocalProcess when Spork is not used with server" do
    Spork::Runner.any_instance.should_receive(:find_test_framework).and_return(nil)
    Spork.should_receive(:using_spork?).and_return(false)
    Spork::RunStrategy::LocalProcess.any_instance.should_receive(:run).and_return(true)
    load File.dirname(__FILE__) + "/../../../lib/spork/local_process.rb"
  end

  it "runs specs in a loop" do
    test_framework = mock_test_framework 
    test_framework.should_not_receive(:additional_options=)

    Readline.should_receive(:readline).with("> 'some_specs' or: ").and_return("\n")
    Spork::RunStrategy::LocalProcess.new(test_framework).run(["some_specs"], STDERR, STDOUT)
  end
  
  it "allows to specify new filter" do
    test_framework = mock_test_framework "other_specs", 2
    test_framework.should_receive(:run_tests).with(["other_specs"], STDERR, STDOUT)
    test_framework.should_not_receive(:additional_options=)
    test_framework.should_receive(:options_str).with("other_specs", nil).and_return("other_specs")

    Readline.should_receive(:readline).with("> 'some_specs' or: ").and_return("other_specs\n")
    Readline.should_receive(:readline).with("> 'other_specs' or: ").and_return("\n")
    Spork::RunStrategy::LocalProcess.new(test_framework).run(["some_specs"], STDERR, STDOUT)
  end

  it "allows to specify additional options" do
    test_framework = mock_test_framework "other_specs", 2
    test_framework.should_receive(:run_tests).with(["other_specs"], STDERR, STDOUT)
    test_framework.should_receive(:additional_options=).with(%q[some additional opts])
    test_framework.should_receive(:options_str).with("other_specs", "some additional opts").and_return(%q[other_specs "some additional opts"])

    Readline.should_receive(:readline).with("> 'some_specs' or: ").and_return(%Q[other_specs "some additional opts"\n])
    Readline.should_receive(:readline).with(%Q[> 'other_specs "some additional opts"' or: ]).and_return("\n")
    Spork::RunStrategy::LocalProcess.new(test_framework).run(["some_specs"], STDERR, STDOUT)
  end

  it "exits the process if 'exit' is specified as a filter" do
    test_framework = mock_test_framework

    Readline.should_receive(:readline).with("> 'some_specs' or: ").and_return("exit\n")
    expect {
      Spork::RunStrategy::LocalProcess.new(test_framework).run(["some_specs"], STDERR, STDOUT)
    }.to raise_exception(SystemExit)
  end

  def mock_test_framework new_filter=nil, loop_count=1
    test_framework = double('TestFramework')
    test_framework.should_receive(:run_tests).with(["some_specs"], STDERR, STDOUT)
    test_framework.should_receive(:options_str).with(["some_specs"], nil).and_return("some_specs")

    test_framework.should_receive(:preload).exactly(loop_count).times
    test_framework.should_receive(:reset).exactly(loop_count).times

    Spork.should_receive(:exec_each_run).exactly(loop_count).times
    Spork.should_receive(:exec_after_each_run).exactly(loop_count).times
    Spork.stub(:using_spork?) {(loop_count -= 1) == -1}    

    test_framework
  end

end
