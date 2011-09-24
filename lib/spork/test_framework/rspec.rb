class Spork::TestFramework::RSpec < Spork::TestFramework
  def reset
    if rspec1?
      raise NotImplementedError
    else
      ::RSpec.instance_eval {@configuration = @world = nil}
    end
  end
end
