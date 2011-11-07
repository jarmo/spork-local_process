require 'rubygems'
require 'spork'
require File.dirname(__FILE__) + '/../test_framework/rspec'
require File.dirname(__FILE__) + '/../ext/tab_completion'

class Spork::RunStrategy::LocalProcess < Spork::RunStrategy

  def run(argv, stderr, stdout)
    $stdout, $stderr = stdout, stderr
    Spork::Ext::TabCompletion.init

    filter = argv
    additional_options = nil

    # in some libedit versions first #push into history won't add the item to
    # the history
    2.times {Readline::HISTORY.push argv.join(" ")}

    while running?
      test_framework.preload

      begin
        run_proc :each
        test_framework.additional_options = additional_options if additional_options
        test_framework.run_tests(filter, stderr, stdout)
        run_proc :after_each
      rescue Exception => e
        puts "#{e.class}: #{e.message}"
        puts e.backtrace
      ensure
        test_framework.reset
      end

      new_filter = Readline.readline("> '#{(filter + (additional_options || [])).join(" ")}' or: ").strip
      exit 0 if new_filter.downcase == "exit"

      unless new_filter.empty?
        Readline::HISTORY.push new_filter
        new_filter, *additional_options = new_filter.split(/\s+/)
        additional_options = nil if additional_options.empty?
        current_filter_without_lineno = filter_without_line_no filter[0]

        if new_filter == "*"
          filter = [current_filter_without_lineno]
        elsif new_filter =~ /^:\d+$/
          filter = [current_filter_without_lineno + new_filter]
        elsif File.exist? filter_without_line_no new_filter
          filter = [new_filter]
        else
          filter = [current_filter_without_lineno]
          additional_options = [new_filter]
        end
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

  def filter_without_line_no filter
    filter.gsub(/:\d+$/, "")
  end

  def run_proc type
    Spork.instance_eval do
      run_procs = send("#{type}_run_procs").dup
      send "exec_#{type}_run"
      instance_variable_set "@#{type}_run_procs", run_procs
    end
  end

  # needed for testing
  def running?
    true
  end

end
