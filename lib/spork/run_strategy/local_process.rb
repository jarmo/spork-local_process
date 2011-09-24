require File.dirname(__FILE__) + '/../test_framework/rspec'

class Spork::RunStrategy::LocalProcess < Spork::RunStrategy

  def run(argv, stderr, stdout)
    $stdout, $stderr = stdout, stderr
    while true
      test_framework.preload      

      begin
        run_proc :each
        test_framework.reset
        test_framework.run_tests(argv, stderr, stdout)
        run_proc :after_each        
      rescue Exception => e
        puts "#{e.class}: #{e.message}"
        puts e.backtrace
      end

      print "\n>> '#{argv.join(" ")}' or: "
      filter = $stdin.gets
      filter.strip!
      exit 0 if filter.downcase == "exit"      
      argv = filter.split(" ") unless filter.empty?
    end
  end

  def self.unload *const_strs
    consts_strs.each do |const_str|
      consts, const_to_remove = const_str.scan(/(.*)::(.*)$/).flatten
      if consts && Object.const_defined?(consts)
        Object.const_get(consts).send(:remove_const, const_to_remove)
      elsif Object.const_defined?(const_str)
        Object.send(:remove_const, const_str)
      end
    end
  end  

  private

  def run_proc type
    Spork.instance_eval do
      run_procs = send("#{type}_run_procs").dup
      send "exec_#{type}_run"
      instance_variable_set "@#{type}_run_procs", run_procs
    end
  end

end

unless Spork.using_spork?
  test_framework = Spork::Runner.new([], STDERR, STDOUT).find_test_framework
  Spork::RunStrategy::LocalProcess.new(test_framework).run(ARGV, STDERR, STDOUT)
end
