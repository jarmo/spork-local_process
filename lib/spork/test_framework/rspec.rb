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
    ::RSpec::configuration.full_description = options.join(" ")
  end
  
end
