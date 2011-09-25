require File.dirname(__FILE__) + '/../test_framework/rspec'
require File.dirname(__FILE__) + '/../ext/tab_completion'

class Spork::RunStrategy::LocalProcess < Spork::RunStrategy

  def run(argv, stderr, stdout)
    $stdout, $stderr = stdout, stderr
    Spork::Ext::TabCompletion.init
    filter = argv.join(" ")
    Readline::HISTORY.push filter

    while true
      test_framework.preload

      begin
        run_proc :each
        test_framework.reset
        test_framework.run_tests(filter.split(" "), stderr, stdout)
        run_proc :after_each
      rescue Exception => e
        puts "#{e.class}: #{e.message}"
        puts e.backtrace
      end

      new_filter = Readline.readline(">> '#{filter}' or: ").strip
      exit 0 if new_filter.downcase == "exit"

      unless new_filter.empty?
        Readline::HISTORY.push new_filter
        filter = new_filter
      end
    end
  end

  def self.unload *consts
    consts.each do |const|
      const_str = const.to_s
      super_consts, const_to_remove = const_str.scan(/(.*)::(.*)$/).flatten
      if super_consts && Object.const_defined?(super_consts)
        Object.const_get(super_consts).send(:remove_const, const_to_remove)
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
