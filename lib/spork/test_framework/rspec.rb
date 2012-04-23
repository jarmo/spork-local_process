class Spork::TestFramework::RSpec < Spork::TestFramework
  def reset
    if rspec1?
      raise NotImplementedError
    else
      ::RSpec.reset
      ::RSpec.configuration.inclusion_filter.clear
    end
  end
  
  def additional_options= options
    ::RSpec::configuration.full_description = options.join(" ")
  end
  
end
