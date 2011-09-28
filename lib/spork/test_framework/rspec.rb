class Spork::TestFramework::RSpec < Spork::TestFramework
  def reset
    if rspec1?
      raise NotImplementedError
    else
      ::RSpec.reset
      ::RSpec.configuration.formatters.clear if ::RSpec.configuration.formatters
      ::RSpec.configuration.clear_inclusion_filter
      ::RSpec.world.shared_example_groups.clear
    end
  end
  
  def additional_options= options
    ::RSpec::configuration.full_description = options
  end
  
  def options_str options, additional_options=nil
    str = options.is_a?(Array) ? options.join(" ") : options
    str.gsub!("\\", "/")
    str << " \"#{additional_options}\"" if additional_options
    str
  end
end
